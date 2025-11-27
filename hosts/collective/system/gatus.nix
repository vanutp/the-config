{pkgs-unstable, ...}: let
  data-dir = "/var/lib/gatus";
  real-data-dir = "/var/lib/private/gatus";
  domain = "status.vanutp.dev";
  port = 8002;
in {
  services.gatus = {
    # TODO: service hardening
    enable = true;
    package = pkgs-unstable.gatus;
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
}
