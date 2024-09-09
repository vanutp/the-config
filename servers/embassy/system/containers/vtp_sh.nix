{...}: {
  virtualisation.composter.apps.vtp_sh.services.frontend = {
    image = "nginx:alpine";
    traefik.host = "vtp.sh";
    volumes = [
      "./content:/app:ro"
      "./default.conf:/etc/nginx/conf.d/default.conf"
    ];
  };
}
