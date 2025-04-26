{...}: {
  virtualisation.composter.apps.pwd_vanutp_dev = {
    backup.enable = true;
    services.vaultwarden = {
      image = "vaultwarden/server:latest";
      traefik = {
        host = "pwd.vanutp.dev";
        port = 80;
      };
      labels = {
        "traefik.http.routers.pwd__vanutp__dev.service" = "pwd__vanutp__dev";
        "traefik.http.routers.pwd__vanutp__dev__ws.rule" = "Host(`pwd.vanutp.dev`) && Path(`/notifications/hub`)";
        "traefik.http.routers.pwd__vanutp__dev__ws.service" = "pwd__vanutp__dev__ws";
        "traefik.http.services.pwd__vanutp__dev__ws.loadbalancer.server.port" = "3012";
      };
      environment = {
        DATABASE_MAX_CONNS = "2";
        WEBSOCKET_ENABLED = "true";
      };
      env_file = "secrets.env";
      volumes = ["./data:/data"];
    };
  };
}
