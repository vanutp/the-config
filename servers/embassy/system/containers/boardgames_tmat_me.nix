{...}: {
  virtualisation.composter.apps.boardgames_tmat_me = {
    services.nginx = {
      image = "registry.vanutp.dev/vanutp/nginx-spa";
      traefik.host = "boardgames.tmat.me";
      volumes = [
        "./content:/app:ro"
      ];
    };
  };
}
