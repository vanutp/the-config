{...}: {
  virtualisation.composter.apps.samat_vk.services.main = {
    image = "registry.vanutp.dev/vanutp/vk-forwarder";
    environment = {
      CHANNEL_ID = "-1002166958176";
      INTERVAL_MINUTES = "10";
      VK_EXCLUDE_SOURCES = builtins.toJSON [
        "testpool"
        "prizrak.artist"
        "club_samsa"
        "simoshasima"
        "olivashko"
        "club198160931"
        "alsushiiiii"
      ];
    };
    env_file = "secrets.env";
    volumes = ["./data:/data"];
  };
}
