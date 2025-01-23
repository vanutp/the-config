{...}: {
  virtualisation.composter.apps.flat-manager = {
    services.flat-manager = {
      build = ".";
      traefik.host = "flat.vanutp.dev";
      environment = {
        GNUPG_HOME = "/data/gpg";
        REPO_CONFIG = "/data/config.json";
      };
      volumes = [
        "./config.json:/data/config.json"
        "./data:/data/data"
        "./gpg:/data/gpg"
      ];
      working_dir = "/data/data";
    };
  };
}
