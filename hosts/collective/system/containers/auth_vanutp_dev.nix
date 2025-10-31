{config, ...}: {
  virtualisation.composter.apps.auth_vanutp_dev = {
    backup.enable = true;
    services = {
      server = {
        # TODO: update asap
        image = "registry.vanutp.dev/vanutp/authentik";
        command = "server";
        env_file = config.sops.secrets."auth_vanutp_dev/server".path;
        volumes = [
          "./media:/media"
          "./custom-templates:/templates"
        ];
        traefik = {
          host = "auth.vanutp.dev";
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
        image = "ghcr.io/goauthentik/server:2025.10.0";
        user = "root";
        command = "worker";
        env_file = config.sops.secrets."auth_vanutp_dev/server".path;
        volumes = [
          "./media:/media"
          "./certs:/certs"
          "./custom-templates:/templates"
        ];
      };
      ldap = {
        image = "ghcr.io/goauthentik/ldap:2025.10.0";
        environment = {
          AUTHENTIK_HOST = "https://auth.vanutp.dev";
          AUTHENTIK_INSECURE = "false";
        };
        env_file = config.sops.secrets."auth_vanutp_dev/ldap".path;
        ports = [
          "100.64.0.6:389:3389"
          "100.64.0.6:636:6636"
        ];
      };
    };
  };
}
