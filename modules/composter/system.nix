{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  options = with lib; {
    virtualisation.composter = {
      vhap-update-host = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      update-dns.enable = mkOption {
        type = types.bool;
        default = false;
      };
      apps = mkOption {
        type = types.attrsOf (types.submodule ({name, ...}: {
          options = {
            auth = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            backup = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = false;
                  };
                  schedule = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
              };
              default = {};
            };
            services = mkOption {
              type = types.nullOr (types.attrsOf types.anything);
              default = null;
              # TODO
              # traefik = mkOption {
              #   type = types.nullOr (types.submodule {
              #     options = {
              #       host = mkOption {
              #         type = types.str;
              #       };
              #       port = mkOption {
              #         type = types.nullOr types.int;
              #         default = null;
              #       };
              #       proxied = mkOption {
              #         type = types.bool;
              #         default = true;
              #       };
              #       update-dns = mkOption {
              #         type = types.bool;
              #         default = true;
              #       };
              #     };
              #   });
              #   default = null;
              # };
            };
            networks = mkOption {
              type = types.nullOr (types.attrsOf types.anything);
              default = null;
            };
            volumes = mkOption {
              type = types.nullOr (types.attrsOf types.anything);
              default = null;
            };
            appDir = mkOption {
              type = types.path;
              readOnly = true;
              default = "/srv/vhap/${name}";
            };
            metadata = mkOption {
              type = types.submodule ({...}: {
                options = {
                  owners = mkOption {
                    type = types.listOf types.int;
                    default = [];
                  };
                };
              });
              default = {};
            };
          };
        }));
        default = {};
      };
    };
  };

  imports = [
    inputs.vhap-compose-update.nixosModules.default
    ./docker.nix
  ];

  config = let
    mkJson = (pkgs.formats.json {}).generate;
    cfg = config.virtualisation.composter;
    configFile = mkJson "config.json" cfg;
    # TODO: validate with vhapd
    # configFile = pkgs.stdenv.mkDerivation {
    #   name = "config.json";
    #   buildInputs = [
    #     pkgs.python3
    #     pkgs.docker-client
    #   ];
    #   phases = ["buildPhase" "checkPhase"];
    #   buildPhase = ''
    #
    # };
    composter =
      pkgs.writers.writePython3Bin "composter" {
        flakeIgnore = ["E501"];
        makeWrapperArgs = [
          "--set"
          "PATH"
          "${lib.makeBinPath [
            pkgs.docker
          ]}"
        ];
      }
      ./composter.py;
  in {
    environment.systemPackages = [
      composter
    ];
    system.activationScripts.composter-activate.text = ''
      ${lib.getExe composter} apply_config ${configFile}
    '';
    systemd.services.composter-up = {
      script = ''
        ${lib.getExe composter} up ${configFile}
      '';
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
    };
    # дикий костыль
    # TODO: мб мержнуть в composter-up?
    systemd.services.composter-restart-on-upgrade = let
      container-names = lib.pipe config.virtualisation.composter.apps [
        (
          lib.mapAttrsToList (
            app-name: app:
              lib.pipe app.services [
                (lib.filterAttrs (
                  _: svc:
                    lib.any (lib.hasPrefix "/var/run/docker.sock:") (svc.volumes or [])
                ))
                (lib.mapAttrsToList (svc-name: svc: "${app-name}-${svc-name}-1"))
              ]
          )
        )
        lib.flatten
        lib.escapeShellArgs
      ];
    in {
      script = ''
        if [[ -z "${container-names}" ]]; then
          exit 0
        fi
        if ! systemctl is-active --quiet docker.service; then
          echo "Skipping restart-on-upgrade: docker is not running"
          exit 0
        fi
        if [[ "$(cut -d. -f1 /proc/uptime)" -lt 120 ]]; then
          echo "Skipping restart-on-upgrade: we just booted"
          exit 0
        fi
        ${lib.getExe pkgs.docker} restart ${container-names}
      '';
      restartTriggers = [
        pkgs.docker
      ];
      after = ["composter-up.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
    };
    services.vhap-compose-update = {
      enable = true;
      # TODO: fix permissions?
      user = "root";
      group = "root";
      host = "127.0.0.1";
      port = 7002;
      baseDir = "/srv/vhap";
      logsDir = "/srv/vhap/_vhap_update_logs";
      entries = [];
    };
    vanutp.traefik.proxies = lib.mkIf (cfg.vhap-update-host != null) [
      {
        host = cfg.vhap-update-host;
        target = "http://127.0.0.1:7002";
      }
    ];
    vanutp.backup.backups = lib.pipe config.virtualisation.composter.apps [
      (lib.filterAttrs (name: app: app.backup.enable))
      (lib.mapAttrs' (name: app: {
        name = "composter-${name}";
        value =
          {
            tag = "composter:${name}";
            paths = lib.pipe app.services [
              builtins.attrValues
              (map (svc: svc.volumes or []))
              lib.flatten
              (map (vol: builtins.elemAt (lib.splitString ":" vol) 0))
              (builtins.filter (lib.hasPrefix "./"))
              (map (vol: app.appDir + (lib.removePrefix "." vol)))
              lib.unique
            ];
          }
          // (
            if app.backup.schedule != null
            then {inherit (app.backup) schedule;}
            else {}
          );
      }))
      (lib.filterAttrs (name: cfg: cfg.paths != []))
    ];
    vanutp.maskman.entries = lib.pipe config.virtualisation.composter.apps [
      builtins.attrValues
      (map (app: builtins.attrValues app.services))
      lib.flatten
      (builtins.filter (svc: svc ? traefik && svc.traefik ? host && (svc.traefik.update-dns or true)))
      (map (svc: {
        name = svc.traefik.host;
        proxied = svc.traefik.proxied or true;
      }))
    ];
  };
}
