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
      valkey = {
        image = "valkey/valkey:9-alpine";
        command = ["valkey-server" "--save" "60" "1" "--loglevel" "warning"];
        volumes = ["./configs/valkey:/data"];
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
          VALKEY_URL = "valkey://valkey:6379/0";
          FLARESOLVERR_URL = "http://flaresolverr:8191";
          DOWNLOAD_DIR = "/media/downloads";
          TV_DIR = "/media/series";
          MOVIES_DIR = "/media/movies";
        };
        volumes = [
          "./configs/requester:/data"
          "${dataDir}:/media"
        ];
        dns = "8.8.8.8";
        traefik = {
          host = "watch.vanutp.dev";
          paths = ["/api" "/docs" "/openapi.json"];
          middlewares = ["authentik@docker"];
          proxied = false;
        };
      };
      requester_nginx = {
        image = "registry.vanutp.dev/vanutp/media-server/nginx";
        restart = "always";
        traefik = {
          host = "watch.vanutp.dev";
          middlewares = ["authentik@docker"];
          proxied = false;
        };
      };
      requester_backend_lumi = {
        image = "registry.vanutp.dev/vanutp/media-server/backend";
        # TODO: move to a constant?
        environment.FORWARDED_ALLOW_IPS = lib.pipe config.virtualisation.docker.daemon.settings.default-address-pools [
          (map (pool: pool.base))
          (builtins.concatStringsSep ",")
        ];
        env_file = config.sops.secrets."media_server_lumi".path;
        user = "1000:2000";
        environment = {
          VALKEY_URL = "valkey://valkey:6379/0";
          FLARESOLVERR_URL = "http://flaresolverr:8191";
          DOWNLOAD_DIR = "/media/downloads";
          TV_DIR = "/media/lumi/series";
          MOVIES_DIR = "/media/lumi/movies";
        };
        volumes = [
          "./configs/requester_lumi:/data"
          "/srv/media:/media"
        ];
        dns = "8.8.8.8";
        traefik = {
          host = "watch.rightarion.ru";
          paths = ["/api" "/docs" "/openapi.json"];
          middlewares = ["authentik@docker"];
          certresolver = "http";
          update-dns = false;
        };
      };
      requester_nginx_lumi = {
        image = "registry.vanutp.dev/vanutp/media-server/nginx";
        traefik = {
          host = "watch.rightarion.ru";
          middlewares = ["authentik@docker"];
          certresolver = "http";
          update-dns = false;
        };
      };
      bitmagnet = {
        image = "ghcr.io/bitmagnet-io/bitmagnet:latest";
        depends_on = gluetunDep;
        network_mode = "service:gluetun";
        traefik = {
          host = "bitmagnet.vanutp.dev";
          port = 3333;
          middlewares = ["authentik@docker"];
          proxied = false;
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

  # TODO: healthchecks

  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/media_server";
      services = ["media_server"];
    }
  ];
}
