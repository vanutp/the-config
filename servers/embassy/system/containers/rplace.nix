# TODO: CURRENTLY UNUSED
{...}: {
  virtualisation.composter.apps.rplace = {
    services = {
      rplace = {
        build = ".";
        command = "serve /data";
        labels = {
          "traefik.http.routers.\${TRAEFIK_MAIN:-rplace}.service" = "\${TRAEFIK_MAIN:-rplace}";
          "traefik.http.routers.\${TRAEFIK_WS:-rplace_ws}.rule" = "Host(`$DOMAIN`)&&Path(`/ws`)";
          "traefik.http.routers.\${TRAEFIK_WS:-rplace_ws}.service" = "\${TRAEFIK_WS:-rplace_ws}";
        };
        traefik = {
          host = "$DOMAIN";
          port = 9000;
        };
        user = "\${UID:-1000}:\${GID:-1000}";
        volumes = ["./data:/data"];
      };
    };
  };
}
