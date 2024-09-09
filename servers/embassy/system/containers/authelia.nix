{...}: {
  virtualisation.composter.apps.authelia = {
    services = {
      admin = {
        image = "registry.vanutp.dev/progtime/authelia-admin:latest";
        traefik = {};
        labels = {
          "traefik.http.routers.authelia-admin.middlewares" = "authelia@docker";
          "traefik.http.routers.authelia-admin.rule" = "Host(`auth.vanutp.dev`) && PathPrefix(`/admin`)";
        };
        environment = {
          APP_NAME = "vanutp SSO Admin";
          FILE_PATH = "/data/users_database.yml";
          PATH_PREFIX = "/admin";
        };
        volumes = [
          "./authelia/users_database.yml:/data/users_database.yml"
        ];
      };
      authelia = {
        image = "authelia/authelia";
        environment = {
          TZ = "Europe/Moscow";
        };
        expose = [9091];
        healthcheck.disable = true;
        labels = {
          "traefik.http.middlewares.authelia.forwardauth.address" = "http://127.0.0.1:9091/api/authz/forward-auth";
          "traefik.http.middlewares.authelia.forwardauth.authResponseHeaders" = "Remote-User,Remote-Groups,Remote-Name,Remote-Email";
          "traefik.http.middlewares.authelia.forwardauth.trustForwardHeader" = "true";
        };
        ports = ["127.0.0.1:9091:9091"];
        traefik.host = "auth.vanutp.dev";
        volumes = [
          "./authelia:/config"
        ];
      };
      redis = {
        image = "redis:alpine";
        environment = {
          TZ = "Europe/Moscow";
        };
        expose = [6379];
        volumes = [
          "./redis:/data"
        ];
      };
    };
  };
}
