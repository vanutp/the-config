{
  pkgs-unstable,
  config,
  lib,
  ...
}: let
  dataDir = "/var/lib/private/gatus";
  cfg = config.vanutp.gatus;
in {
  options = with lib; {
    # TODO: expose all options, move to modules
    vanutp.gatus = {
      enable = mkEnableOption "Gatus";
      port = mkOption {
        type = types.int;
        default = 8002;
      };
      domain = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      secrets = mkOption {
        type = types.attrsOf types.str;
        default = {};
      };
      checks = mkOption {
        # TODO: fully type
        type = types.attrsOf types.anything;
        default = {};
      };
      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
      };
    };
  };
  config = lib.mkIf cfg.enable {
    sops.templates."gatus.env".content =
      lib.concatLines
      (lib.mapAttrsToList (name: value: "${name}=${config.sops.placeholder.${value}}") cfg.secrets);
    services.gatus = {
      # TODO: service hardening
      enable = true;
      package = pkgs-unstable.gatus;
      environmentFile = config.sops.templates."gatus.env".path;
      settings = lib.mkMerge [
        {
          web.port = cfg.port;
          storage = {
            type = "sqlite";
            path = "$STATE_DIRECTORY/gatus.db";
          };
          ui = {
            title = "vanutp services status";
            dashboard-heading = "vanutp services status";
            dashboard-subheading = "";
            custom-css = ''
              header { display: none; }
            '';
          };
          endpoints =
            lib.mapAttrsToList (
              name: check:
                {
                  name = assert lib.assertMsg (!(check ? "name")) "Check body can't contain name attribute"; name;
                  interval = "30s";
                }
                // check
            )
            cfg.checks;
        }
        cfg.extraConfig
      ];
    };
    vanutp.backup.backups.gatus = {
      paths = [dataDir];
    };
    vanutp.maskman.entries = lib.mkIf (cfg.domain != null) [
      {
        name = cfg.domain;
        proxied = false;
      }
    ];
    vanutp.traefik.proxies = lib.mkIf (cfg.domain != null) [
      {
        host = cfg.domain;
        target = "http://localhost:${builtins.toString cfg.port}";
      }
    ];
  };
}
