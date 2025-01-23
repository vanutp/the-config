# TODO: update authelia configs
{...}: {
  virtualisation.composter.apps.sso_adventures_lab_ru.services = {
    admin = {
      environment = {
        APP_NAME = "Adventures Lab SSO Admin";
        FILE_PATH = "/data/users_database.yml";
        PATH_PREFIX = "/admin";
      };
      image = "registry.vanutp.dev/progtime/authelia-admin:latest";
      labels = {
        "traefik.http.routers.authelia-al-admin.middlewares" = "authelia-al@docker";
        "traefik.http.routers.authelia-al-admin.rule" = "Host(`sso.adventures-lab.ru`) && PathPrefix(`/admin`)";
      };
      traefik = {};
      volumes = [
        "./authelia/users_database.yml:/data/users_database.yml"
      ];
    };
    authelia = {
      environment = {TZ = "Europe/Moscow";};
      expose = [9092];
      healthcheck.disable = true;
      image = "authelia/authelia";
      labels = {
        "traefik.http.middlewares.authelia-al.forwardauth.address" = "http://127.0.0.1:9092/api/verify?rd=https://sso.adventures-lab.ru";
        "traefik.http.middlewares.authelia-al.forwardauth.authResponseHeaders" = "Remote-User,Remote-Groups,Remote-Name,Remote-Email";
        "traefik.http.middlewares.authelia-al.forwardauth.trustForwardHeader" = "true";
        # there are no credentials to set dns records for adventures-lab.ru
        "traefik.http.routers.sso__adventures-lab__ru.tls.certresolver" = "http";
      };
      ports = ["127.0.0.1:9092:9092"];
      traefik = {
        host = "sso.adventures-lab.ru";
        port = 9092;
      };
      volumes = ["./authelia:/config"];
    };
    redis = {
      environment = {
        TZ = "Europe/Moscow";
      };
      expose = [6379];
      image = "redis:alpine";
      volumes = ["./redis:/data"];
    };
  };
}
