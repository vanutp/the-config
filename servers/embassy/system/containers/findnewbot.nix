{...}: {
  virtualisation.composter.apps.findnewbot = {
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/fnb/findnewbot:latest";
      traefik = {
        host = "pinger.vanutp.dev";
        port = 8025;
      };
      volumes = [
        "./data:/data"
        "./config.py:/app/config.py:ro"
      ];
    };
  };
}
