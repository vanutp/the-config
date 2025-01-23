{...}: {
  virtualisation.composter.apps.avataremojibot.services.main = {
    image = "ghcr.io/tm-a-t/avataremojibot:latest";
    env_file = "secrets.env";
    volumes = [
      "./data:/data"
    ];
  };
}
