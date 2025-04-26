{...}: {
  virtualisation.composter.apps.vanutp_music_bot = {
    backup.enable = true;
    services.main = {
      image = "ghcr.io/vanutp/spotify-bot:latest";
      environment = {
        SPOTIFY_REDIRECT_URI = "http://localhost:8088";
        OWNER_ID = "304493639";
      };
      env_file = "secrets.env";
      volumes = ["./data:/data"];
    };
  };
}
