{
  config,
  lib,
  ...
}: let
  dataDir = "/srv/media";
  uid = 1000;
  gid = 2000;
in {
  # TODO: как-нибудь поставить деп контейнера от фс?
  fileSystems."${dataDir}" = {
    device = "memory-hole:${dataDir}";
    fsType = "nfs";
  };

  users.groups.media-server = {
    members = ["fox"];
    inherit gid;
  };

  virtualisation.composter.apps.media_server = let
    linuxserverEnv = {
      PUID = builtins.toString uid;
      PGID = builtins.toString gid;
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
    auth = ["foxlab"];
    services = {
      gluetun = {
        image = "qmcgaw/gluetun";
        cap_add = ["NET_ADMIN"];
        hostname = "media-server";
        devices = ["/dev/net/tun:/dev/net/tun"];
        environment = {
          VPN_SERVICE_PROVIDER = "custom";
          VPN_TYPE = "wireguard";
        };
        env_file = config.sops.secrets."media_server/gluetun_env".path;
      };
      jellyfin = {
        image = "lscr.io/linuxserver/jellyfin:latest";
        hostname = "media-server";
        traefik = {
          host = "jellyfin.vanutp.dev";
          port = 8096;
          proxied = false;
        };
        environment =
          linuxserverEnv
          // {
            JELLYFIN_PublishedServerUrl = "https://jellyfin.vanutp.dev";
          };
        volumes = [
          "./configs/jellyfin:/config"
          "${dataDir}:/media"
        ];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        environment = {
          LOG_LEVEL = "info";
        };
      };
      requester_backend = {
        image = "registry.vanutp.dev/vanutp/media-server/backend";
        # TODO: move to a constant?
        environment.FORWARDED_ALLOW_IPS = lib.pipe config.virtualisation.docker.daemon.settings.default-address-pools [
          (map (pool: pool.base))
          (builtins.concatStringsSep ",")
        ];
        env_file = config.sops.secrets."media_server/requester_env".path;
        user = "${builtins.toString uid}:${builtins.toString gid}";
        environment = {
          QBITTORRENT_URL = "http://memory-hole:8080";
          FLARESOLVERR_URL = "http://flaresolverr:8191";
          DOWNLOAD_DIR = "/media/downloads";
          TV_DIR = "/media/series";
          MOVIES_DIR = "/media/movies";
        };
        volumes = [
          "./configs/requester:/data"
          "${dataDir}:/media"
        ];
        restart = "always";
      };
      requester_nginx = {
        image = "registry.vanutp.dev/vanutp/media-server/nginx";
        restart = "always";
        traefik = {
          host = "watch.vanutp.dev";
          proxied = false;
        };
        labels = {
          "traefik.http.routers.watch__vanutp__dev.middlewares" = "authentik@docker";
        };
      };
      bitmagnet = {
        image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
        depends_on = gluetunDep;
        network_mode = "service:gluetun";
        traefik = {
          host = "bitmagnet.vanutp.dev";
          port = 3333;
          update-dns = false;
        };
        labels = {
          "traefik.http.middlewares.tardis_only.ipwhitelist.sourcerange" = "100.91.142.4/32";
          "traefik.http.routers.bitmagnet__vanutp__dev.middlewares" = "tardis_only@docker";
        };
        env_file = config.sops.secrets."media_server/bitmagnet_env".path;
        volumes = [
          "./configs/bitmagnet:/root/.config/bitmagnet"
        ];
        command = [
          "worker"
          "run"
          "--keys=http_server"
          "--keys=queue_server"
          "--keys=dht_crawler"
        ];
      };
    };
  };

  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/media_server";
      services = ["media_server"];
    }
  ];
  vanutp.maskman.entries = [
    {
      name = "bitmagnet.vanutp.dev";
      target-interface = "tailscale0";
      proxied = false;
    }
  ];
}
