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
  services.gatus.settings.endpoints = [
    {
      name = "synapse";
      url = "https://matrix.vanutp.dev/_matrix/client/versions";
      interval = "30s";
      conditions = [
        "[STATUS] == 200"
        "has([BODY].versions) == true"
      ];
    }
  ];
}
