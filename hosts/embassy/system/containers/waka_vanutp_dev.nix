{config, ...}: {
  virtualisation.composter.apps.waka_vanutp_dev.services.wakapi = {
    # waiting for https://github.com/muety/wakapi/pull/879
    image = "registry.vanutp.dev/vanutp/wakapi:latest";
    traefik = {
      host = "waka.vanutp.dev";
      proxied = false;
    };
    env_file = config.sops.secrets.wakapi.path;
    environment = {
      WAKAPI_DB_TYPE = "postgres";
      WAKAPI_DB_HOST = "10.1.0.4";
      WAKAPI_DB_PORT = "5432";
      WAKAPI_DB_USER = "wakapi";
      WAKAPI_DB_NAME = "wakapi";

      WAKAPI_INSECURE_COOKIES = "false";
      WAKAPI_ALLOW_SIGNUP = "false";
      WAKAPI_PUBLIC_URL = "https://waka.vanutp.dev";

      WAKAPI_OIDC_ALLOW_SIGNUP = "true";
      WAKAPI_OIDC_PROVIDERS_0_NAME = "authentik";
      WAKAPI_OIDC_PROVIDERS_0_DISPLAY_NAME = "vanutp one";
      WAKAPI_OIDC_PROVIDERS_0_ENDPOINT = "https://one.vanutp.dev/application/o/wakapi/";
    };
  };
}
