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
      update-dns = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
            };
            cloudflare-key-file = mkOption {
              type = types.str;
              readOnly = true;
            };
            host-ip = mkOption {
              type = types.str;
              readOnly = true;
            };
          };
        };
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
    cfg =
      (builtins.removeAttrs config.virtualisation.composter ["update-dns"])
      // {
        update-dns = let
          dnsCfg = config.virtualisation.composter.update-dns;
        in (
          if dnsCfg.enable
          then dnsCfg
          else {enable = false;}
        );
      };
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
        libraries = [pkgs.python3Packages.httpx];
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
    virtualisation.composter.update-dns = {
      host-ip =
        builtins.elemAt
        (lib.strings.splitString "/" config.setup.network.ipv4.address)
        0;
      cloudflare-key-file = config.sops.secrets."vhap-cf-token".path;
    };
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
      };
    };
    services.vhap-compose-update = {
      enable = true;
      # TODO: fix permissions?
      user = "root";
      group = "root";
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
  };
}
