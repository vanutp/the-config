{
  pkgs-unstable,
  config,
  lib,
  ...
}: let
  data-dir = "/var/lib/gatus";
  real-data-dir = "/var/lib/private/gatus";
  domain = "status.vanutp.dev";
  port = 8002;
in {
  options = with lib; {
    # TODO: expose all options, move to modules
    vanutp.gatus.secrets = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
  };
  config = {
    sops.templates."gatus.env".content =
      lib.concatLines
      (lib.mapAttrsToList (name: value: "${name}=${config.sops.placeholder.${value}}") config.vanutp.gatus.secrets);
    services.gatus = {
      # TODO: service hardening
      enable = true;
      package = pkgs-unstable.gatus;
      environmentFile = config.sops.templates."gatus.env".path;
      settings = {
        web.port = 8002;
        storage = {
          type = "sqlite";
          path = "${data-dir}/gatus.db";
        };
        ui = {
          title = "vanutp services status";
          dashboard-heading = "vanutp services status";
          dashboard-subheading = "";
          custom-css = ''
            header { display: none; }
          '';
        };
      };
    };
    vanutp.backup.backups.gatus = {
      paths = [real-data-dir];
      extraBackupArgs = ["-vv"];
    };
    vanutp.maskman.entries = [
      {
        name = domain;
        proxied = false;
      }
    ];
    vanutp.traefik.proxies = [
      {
        host = domain;
        target = "http://localhost:${builtins.toString port}";
      }
    ];
  };
}
