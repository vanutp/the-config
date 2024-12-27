{config, ...}: {
  virtualisation.composter.apps.samat_yt.services = {
    redis = {
      image = "redis:alpine";
    };
    main = {
      image = "bennythink/ytdlbot";
      environment = {
        PYRO_WORKERS = "8";
        OWNER = "Rightarion";
        ENABLE_FFMPEG = "True";
      };
      env_file = config.sops.secrets."services/samat_yt".path;
      volumes = [
        "./data/vnstat/:/var/lib/vnstat/"
      ];
    };
  };
  sops.secrets."services/samat_yt" = {};
}
