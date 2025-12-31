{config, ...}: {
  virtualisation.composter.apps.authentik.services = {
    outpost = {
      image = "ghcr.io/goauthentik/proxy:2025.10";
      environment = {
        AUTHENTIK_HOST = "https://one.vanutp.dev";
        AUTHENTIK_INSECURE = "false";
      };
      env_file = config.sops.secrets.authentik_outpost.path;
      labels = {
        "traefik.enable" = "true";
        "traefik.http.middlewares.authentik.forwardauth.address" = "http://127.0.0.1:9000/outpost.goauthentik.io/auth/traefik";
        "traefik.http.middlewares.authentik.forwardauth.trustForwardHeader" = "true";
        "traefik.http.middlewares.authentik.forwardauth.authResponseHeaders" = "X-authentik-username,X-authentik-groups,X-authentik-entitlements,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version,X-telegram-id";
      };
      ports = ["127.0.0.1:9000:9000"];
    };
  };
}
