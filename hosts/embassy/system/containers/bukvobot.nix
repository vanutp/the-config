{...}: {
  virtualisation.composter.apps.bukvobot = {
    auth = ["foxlab"];
    services.bot = {
      image = "registry.vanutp.dev/fnb/bukvobot:latest";
      volumes = [
        "./config.py:/app/config.py:ro"
        "./data:/data"
      ];
    };
  };
}
