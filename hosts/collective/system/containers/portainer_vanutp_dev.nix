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
  vanutp.gatus.secrets.PORTAINER_KEY = "portainer/gatus_token";
  services.gatus.settings.endpoints = [
    {
      name = "portainer";
      url = "https://portainer.vanutp.dev/api/endpoints";
      headers."X-API-Key" = "$PORTAINER_KEY";
      interval = "30s";
      conditions = [
        "[STATUS] == 200"
        "[BODY][0].Status == 1"
      ];
    }
  ];
}
