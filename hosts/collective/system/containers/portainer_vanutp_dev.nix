{...}: {
  virtualisation.composter.apps.portainer_vanutp_dev.services.main = {
    image = "portainer/portainer-ce:lts";
    traefik = {
      host = "portainer.vanutp.dev";
      port = 9000;
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "./data:/data"
    ];
  };
}
