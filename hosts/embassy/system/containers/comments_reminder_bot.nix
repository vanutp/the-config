{...}: {
  virtualisation.composter.apps.comments_reminder_bot = {
    auth = ["ghcr"];
    services.main = {
      image = "ghcr.io/tm-a-t/comments_reminder_bot:latest";
      volumes = [
        "./config.py:/app/config.py:ro"
      ];
    };
  };
}
