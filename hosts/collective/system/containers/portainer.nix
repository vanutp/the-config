{...}: {
  virtualisation.composter.apps.portainer.services.main = {
    image = "portainer/agent:2.21.0";
    ports = [
      "10.1.0.6:9001:9001"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/docker/volumes:/var/lib/docker/volumes"
    ];
  };
}
