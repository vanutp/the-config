{...}: {
  virtualisation.composter.apps.hacker = {
    auth = ["foxlab"];
    services = {
      bot = {
        image = "registry.vanutp.dev/tm_a_t/hacker/bot:latest";
        volumes = [
          "./config.py:/app/config.py:ro"
          "./data:/data"
        ];
      };
      web = {
        image = "registry.vanutp.dev/tm_a_t/hacker/web:latest";
        traefik.host = "hacker.tmat.me";
        volumes = [
          "./config.py:/app/config.py:ro"
        ];
      };
    };
  };
}
