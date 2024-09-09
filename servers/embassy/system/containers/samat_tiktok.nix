{...}: {
  virtualisation.composter.apps.samat_tiktok.services = {
    main = {
      image = "ghcr.io/vanutp/tiktok2telegram:latest";
      depends_on = ["redis"];
      environment = {
        EXCLUDED_HASHTAGS_FILE = "hashtags.txt";
        REDIS_SET_KEY = "tiktok_posted";
        REDIS_URL = "redis://redis";
        TELEGRAM_CHANNEL_ID = "-1001501810341";
        TELEGRAM_OWNER_ID = "550578377";
        TIKTOK_CHECK_PERIOD_MAX = "300000";
        TIKTOK_CHECK_PERIOD_MIN = "180000";
        TIKTOK_SEC_UID = "MS4wLjABAAAAA7FNRArU9pUvQaUyQf6wm157BACKar4KtXhMaotHuvLRgSkPYt-hNi6tYwo2lhoe";
      };
      env_file = "secrets.env";
    };
    redis = {
      image = "redis:alpine";
      volumes = ["./data:/data"];
    };
  };
}
