{...}: {
  virtualisation.composter.apps.anti_discuss_bot.services.main = {
    image = "registry.vanutp.dev/vanutp/anti_discuss_bot:latest";
    env_file = "secrets.env";
    volumes = ["./data:/data"];
  };
}
