{config, ...}: {
  # TODO: common redirect setting?
  vanutp.traefik.extraDynamicConfig = {
    http.routers.auth_vanutp_dev = {
      rule = "Host(`auth.vanutp.dev`)";
      middlewares = ["auth_vanutp_dev"];
      service = "noop@internal";
    };
    http.middlewares.auth_vanutp_dev.redirectregex = {
      regex = "^https://auth\\.vanutp\\.dev/(.*)";
      replacement = "https://one.vanutp.dev/\${1}";
    };
  };
  virtualisation.composter.apps.one_vanutp_dev = {
    backup.enable = true;
    services = {
      server = {
        # TODO: update asap
        # image = "ghcr.io/goauthentik/server:2025.10";
        image = "registry.vanutp.dev/vanutp/authentik";
        depends_on = ["pgbouncer"];
        command = "server";
        environment = {
          AUTHENTIK_POSTGRESQL__DISABLE_SERVER_SIDE_CURSORS = "true";
        };
        env_file = config.sops.secrets."one_vanutp_dev/server".path;
        volumes = [
          "./media:/media"
          "./custom-templates:/templates"
        ];
        traefik = {
          host = "one.vanutp.dev";
          port = 9000;
        };
        labels = {
          "traefik.http.middlewares.authentik.forwardauth.address" = "http://127.0.0.1:9000/outpost.goauthentik.io/auth/traefik";
          "traefik.http.middlewares.authentik.forwardauth.trustForwardHeader" = "true";
          "traefik.http.middlewares.authentik.forwardauth.authResponseHeaders" = "X-authentik-username,X-authentik-groups,X-authentik-entitlements,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version,X-telegram-id";
        };
        ports = ["127.0.0.1:9000:9000"];
      };
      worker = {
        # TODO: update asap
        # image = "ghcr.io/goauthentik/server:2025.10";
        image = "registry.vanutp.dev/vanutp/authentik";
        depends_on = ["pgbouncer"];
        user = "root";
        command = "worker";
        environment = {
          AUTHENTIK_POSTGRESQL__DISABLE_SERVER_SIDE_CURSORS = "true";
        };
        env_file = config.sops.secrets."one_vanutp_dev/server".path;
        volumes = [
          "./media:/media"
          "./certs:/certs"
          "./custom-templates:/templates"
        ];
      };
      ldap = {
        image = "ghcr.io/goauthentik/ldap:2025.10.0";
        depends_on = ["server"];
        environment = {
          AUTHENTIK_HOST = "https://one.vanutp.dev";
          AUTHENTIK_INSECURE = "false";
        };
        env_file = config.sops.secrets."one_vanutp_dev/ldap".path;
        ports = [
          "100.64.0.6:389:3389"
          "100.64.0.6:636:6636"
        ];
      };
      # TODO: remove
      pgbouncer = {
        image = "edoburu/pgbouncer:v1.24.1-p1@sha256:3db3d7223e93af52b4116f642951a1a5fa44702a88c2a59cf7562cac19320c9e";
        environment = {
          AUTH_TYPE = "scram-sha-256";
          IGNORE_STARTUP_PARAMETERS = "search_path";
        };
        env_file = config.sops.secrets."one_vanutp_dev/pgbouncer".path;
      };
    };
  };
}
