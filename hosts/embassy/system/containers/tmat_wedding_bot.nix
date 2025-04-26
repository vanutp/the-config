{...}: {
  virtualisation.composter.apps.tmat_wedding_bot = {
    backup.enable = true;
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/tm_a_t/notifications-and-feedback-bot:latest";
      volumes = [
        "./data:/data"
        "./config.py:/app/config.py:ro"
      ];
    };
  };
}
