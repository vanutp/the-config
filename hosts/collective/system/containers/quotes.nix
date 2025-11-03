{config, ...}: {
  virtualisation.composter.apps.quotes.services = {
    bot = {
      image = "registry.vanutp.dev/vanutp/quote-bot:latest";
      environment.QUOTE_API_URL = "http://api:3000";
      env_file = config.sops.secrets."quotes/bot".path;
      volumes = ["./data:/app/data"];
    };
    api = {
      image = "registry.vanutp.dev/vanutp/quote-api:latest";
      env_file = config.sops.secrets."quotes/api".path;
      traefik.host = "quotes.vanutp.dev";
    };
  };
}
