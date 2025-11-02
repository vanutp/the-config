{...}: {
  virtualisation.composter.apps.work_adventures_lab_ru = {
    auth = ["foxlab-nocodb"];
    services.nocodb = {
      environment = {
        NC_AUTH_AUTHELIA_CREATOR_GROUP = "nocodb:create";
        NC_AUTH_AUTHELIA_ENABLED = true;
        NC_AUTH_AUTHELIA_SUPER_GROUP = "nocodb:super";
        NC_AUTH_AUTHELIA_URL = "https://sso.adventures-lab.ru";
        NC_DISABLE_TELE = true;
        NC_INVITE_ONLY_SIGNUP = true;
      };
      env_file = "secrets.env";
      image = "registry.vanutp.dev/progtime/nocodb:latest";
      labels = {
        "traefik.http.routers.work__adventures-lab__ru.tls.certresolver" = "http";
      };
      traefik = {
        host = "work.adventures-lab.ru";
        middlewares = ["authelia-al@docker"];
        certresolver = "http";
      };
      volumes = ["./data:/usr/app/data"];
    };
  };
}
