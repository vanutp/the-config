{...}: {
  virtualisation.composter.apps.mc_auth_vanutp_dev = {
    backup.enable = true;
    services.main = {
      image = "registry.vanutp.dev/minecraft/tgauth-backend:latest";
      traefik = {
        host = "mc-auth.vanutp.dev";
        proxied = false;
      };
      environment = {
        SERVER_BASE = "https://mc-auth.vanutp.dev/";
        YGG_KEY_PATH = "/config/key.der";
      };
      env_file = "secrets.env";
      volumes = [
        "./data:/data"
        "./key.der:/config/key.der"
      ];
    };
  };
}
