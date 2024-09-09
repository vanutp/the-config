{
  lib,
  config,
  pkgs,
  ...
}: {
  options = with lib; {
    virtualisation.composter = {
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
          };
        }));
        default = {};
      };
    };
  };

  imports = [
    {
      # TODO: optional podman
      # it supports running systemd in container, which is useful for progtime
      virtualisation.oci-containers.backend = "docker";
      users.extraGroups.docker.members = ["fox"];
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          bip = "10.254.254.1/24";
          default-address-pools = [
            {
              base = "10.254.0.0/16";
              size = 28;
            }
          ];
          ipv6 = true;
          fixed-cidr-v6 = "fd00:dead:beef:c0::/80";
          experimental = true;
        };
      };
    }
  ];

  config = let
    mkJson = (pkgs.formats.json {}).generate;
    configFile = mkJson "config.json" config.virtualisation.composter;
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
  };
}
