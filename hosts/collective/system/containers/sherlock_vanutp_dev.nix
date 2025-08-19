{config, ...}: {
  virtualisation.composter.apps.sherlock_vanutp_dev = {
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/vanutp/sherlock";
      env_file = config.sops.secrets."sherlock".path;
      traefik = {
        host = "sherlock.vanutp.dev";
        proxied = false;
      };
      volumes = [
        "./data:/data"
      ];
    };
  };
}
