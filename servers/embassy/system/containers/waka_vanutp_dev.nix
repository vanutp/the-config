{...}: {
  virtualisation.composter.apps.waka_vanutp_dev.services.wakapi = {
    # TODO: update shit
    image = "registry.vanutp.dev/vanutp/wakapi";
    traefik = {
      host = "waka.vanutp.dev";
      port = 3000;
    };
    environment = {
      WAKAPI_ALLOW_SIGNUP = "false";
      WAKAPI_DB_TYPE = "postgres";
      WAKAPI_DB_MAX_CONNECTIONS = "1";
      WAKAPI_MAIL_ENABLED = "true";
      WAKAPI_MAIL_PROVIDER = "smtp";
      WAKAPI_VIBRANT_COLOR = "true";
    };
    env_file = "secrets.env";
  };
}
