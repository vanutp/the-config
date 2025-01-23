{...}: {
  virtualisation.composter.apps.portainer.services.main = {
    image = "portainer/portainer-ce:latest";
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
