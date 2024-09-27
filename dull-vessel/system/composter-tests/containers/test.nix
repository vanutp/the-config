{...}: {
  virtualisation.composter.apps.test.services.main = {
    image = "nginx:alpine";
    traefik.host = "test.vtp.sh";
  };
}
