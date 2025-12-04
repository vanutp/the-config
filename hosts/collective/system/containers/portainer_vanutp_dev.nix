{pkgs, ...}: {
  virtualisation.composter.apps.portainer_vanutp_dev.services.main = {
    image = "portainer/portainer-ce:lts";
    traefik = {
      host = "portainer.vanutp.dev";
      port = 9000;
    };
    labels = {
      "dev.vanutp.portainer-restarter" = pkgs.docker;
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "./data:/data"
    ];
  };

  vanutp.gatus = {
    secrets.PORTAINER_KEY = "portainer/gatus_token";
    checks.portainer = {
      url = "https://portainer.vanutp.dev/api/endpoints";
      headers."X-API-Key" = "$PORTAINER_KEY";
      conditions = [
        "[STATUS] == 200"
        "[BODY][0].Status == 1"
      ];
    };
  };
}
