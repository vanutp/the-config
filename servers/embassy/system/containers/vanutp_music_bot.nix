{...}: {
  virtualisation.composter.apps.vanutp_music_bot.services.main = {
    image = "ghcr.io/vanutp/spotify-bot:latest";
    environment = {
      PROXY = "socks5://s1-proxy:UiHMXAUessu4AG@10.1.0.5:1080/";
      SPOTIFY_REDIRECT_URI = "http://localhost:8088";
      OWNER_ID = "304493639";
    };
    env_file = "secrets.env";
    volumes = ["./data:/data"];
  };
}
