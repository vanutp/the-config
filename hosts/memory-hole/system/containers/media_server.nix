{config, ...}: let
  cfg = config.vanutp.volumes.media-server;
in {
  virtualisation.composter.apps.media_server = let
    linuxserverEnv = {
      PUID = builtins.toString cfg.uid;
      PGID = builtins.toString cfg.gid;
      TZ = "Europe/Berlin";
    };
    gluetunDep = {
      gluetun = {
        condition = "service_healthy";
        restart = true;
      };
    };
  in {
    backup.enable = true;
    services = {
      gluetun = {
        image = "qmcgaw/gluetun";
        cap_add = ["NET_ADMIN"];
        devices = ["/dev/net/tun:/dev/net/tun"];
        environment = {
          VPN_SERVICE_PROVIDER = "custom";
          VPN_TYPE = "wireguard";
          FIREWALL_VPN_INPUT_PORTS = "6881";
        };
        env_file = config.sops.secrets."media_server/gluetun_env".path;
        ports = [
          "100.105.161.120:8080:8080"
        ];
      };
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:libtorrentv1";
        depends_on = gluetunDep;
        network_mode = "service:gluetun";
        traefik = {
          host = "qbt-int.vanutp.dev";
          port = 8080;
          update-dns = false;
          middlewares = ["qbt_int__vanutp__dev@docker"];
        };
        labels = {
          "traefik.http.middlewares.qbt_int__vanutp__dev.ipwhitelist.sourcerange" = "100.91.142.4/32,100.70.145.60/32";
        };
        environment = linuxserverEnv;
        volumes = [
          "./configs/qbittorrent:/config"
          "${cfg.path}:/media"
        ];
      };
      qui = {
        image = "ghcr.io/autobrr/qui:latest";
        depends_on = gluetunDep;
        network_mode = "service:gluetun";
        traefik = {
          host = "qbt.vanutp.dev";
          port = 7476;
          proxied = false;
        };
        env_file = config.sops.secrets."media_server/qui".path;
        environment = {
          QUI__OIDC_ENABLED = "true";
          QUI__OIDC_ISSUER = "https://one.vanutp.dev/application/o/qui/";
          QUI__OIDC_REDIRECT_URL = "https://qbt.vanutp.dev/api/auth/oidc/callback";
          QUI__OIDC_DISABLE_BUILT_IN_LOGIN = "true";
        };
        volumes = [
          "./configs/qui:/config"
        ];
      };
    };
  };

  vanutp.maskman.entries = [
    {
      name = "qbt-int.vanutp.dev";
      target-interface = "tailscale0";
      proxied = false;
    }
  ];
}
