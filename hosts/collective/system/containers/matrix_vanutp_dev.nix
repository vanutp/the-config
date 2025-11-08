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
}
