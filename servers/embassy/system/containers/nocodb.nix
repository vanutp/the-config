{...}: {
  virtualisation.composter.apps.nocodb = {
    auth = ["foxlab"];
    services = {
      nocodb = {
        image = "registry.vanutp.dev/progtime/nocodb:latest";
        traefik.host = "db.vanutp.dev";
        environment = {
          NC_INVITE_ONLY_SIGNUP = true;
          NC_REDIS_URL = "redis://redis";
        };
        env_file = "secrets.env";
        volumes = ["./data:/usr/app/data"];
      };
      redis = {
        image = "redis";
        volumes = ["./redis:/data"];
      };
    };
  };
}
