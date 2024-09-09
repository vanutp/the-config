{...}: {
  virtualisation.composter.apps.t_vanutp_dev = {
    services = {
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        traefik = {
          host = "t.vanutp.dev";
          port = 8080;
        };
        labels = {
          "traefik.http.middlewares.tardis_only.ipwhitelist.sourcerange" = "10.1.1.2/32";
          "traefik.http.routers.t__vanutp__dev.middlewares" = "tardis_only@docker";
        };
        environment = {
          FIREWALL_OUTBOUND_SUBNETS = "10.1.0.0/16";
          PGID = "1000";
          PUID = "1000";
          TZ = "Europe/Moscow";
          WEBUI_PORT = "8080";
        };
        volumes = [
          "./config:/config"
          "./downloads:/downloads"
        ];
      };
      nginx = {
        image = "nginx";
        traefik = {};
        labels = {
          "traefik.http.routers.t_vanutp_dev_streaming.middlewares" = "tardis_only@docker";
          "traefik.http.routers.t_vanutp_dev_streaming.rule" = "Host(`t.vanutp.dev`) && PathPrefix(`/dl`)";
        };
        volumes = [
          "./downloads:/downloads"
          "./nginx.conf:/etc/nginx/conf.d/default.conf"
        ];
      };
    };
  };
}