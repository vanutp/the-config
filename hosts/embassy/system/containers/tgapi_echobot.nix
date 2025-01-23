{...}: {
  virtualisation.composter.apps.tgapi_echobot.services.bot = {
    image = "registry.vanutp.dev/vanutp/tgapi_echobot:latest";
    environment = {
      ADMINS = "304493639";
    };
    env_file = "secrets.env";
    volumes = ["./data:/data"];
  };
}
