{...}: {
  virtualisation.composter.apps.matrix_vanutp_dev = {
    backup.enable = true;
    services.synapse = {
      image = "ghcr.io/element-hq/synapse";
      traefik = {
        host = "matrix.vanutp.dev";
        proxied = false;
      };
      volumes = ["./data:/data"];
    };
  };
  vanutp.gatus.checks.synapse = {
    url = "https://matrix.vanutp.dev/_matrix/client/versions";
    conditions = [
      "[STATUS] == 200"
      "has([BODY].versions) == true"
    ];
  };
}
