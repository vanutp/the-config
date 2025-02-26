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
      apps = mkOption {
        type = types.attrsOf (types.submodule ({name, ...}: {
          options = {
            auth = mkOption {
              type = types.listOf types.str;
              default = [];
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
    composter = pkgs.writers.writePython3 "composter" {flakeIgnore = ["E501"];} ./composter.py;
  in {
    system.activationScripts.composter-activate.text = ''
      ${composter} apply_config ${configFile}
    '';
    systemd.services.composter-up = {
      script = ''
        export PATH=${pkgs.docker}/bin:$PATH
        ${composter} up ${configFile}
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
      port = 7000;
      baseDir = "/srv/vhap";
      logsDir = "/srv/vhap/_vhap_update_logs";
      entries = [];
    };
    vanutp.traefik.proxies = lib.mkIf (cfg.vhap-update-host != null) [
      {
        host = cfg.vhap-update-host;
        target = "http://127.0.0.1:7000";
      }
    ];
  };
}
