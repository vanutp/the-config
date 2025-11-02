{
  config,
  lib,
  ...
}: {
  virtualisation.composter.apps.media_server_lumi = {
    backup.enable = true;
    auth = ["foxlab"];
    services = {
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
        env_file = config.sops.secrets."media_server_lumi".path;
        user = "1000:2000";
        environment = {
          QBITTORRENT_URL = "http://memory-hole:8080";
          FLARESOLVERR_URL = "http://flaresolverr:8191";
          DOWNLOAD_DIR = "/media/downloads";
          TV_DIR = "/media/lumi/series";
          MOVIES_DIR = "/media/lumi/movies";
        };
        volumes = [
          "./configs/requester:/data"
          "/srv/media:/media"
        ];
        traefik = {
          host = "watch.rightarion.ru";
          paths = ["/api" "/docs" "/openapi.json"];
          middlewares = ["authentik@docker"];
          certresolver = "http";
          update-dns = false;
        };
      };
      requester_nginx = {
        image = "registry.vanutp.dev/vanutp/media-server/nginx";
        traefik = {
          host = "watch.rightarion.ru";
          middlewares = ["authentik@docker"];
          certresolver = "http";
          update-dns = false;
        };
      };
    };
  };

  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/media_server_lumi";
      services = ["media_server_lumi"];
    }
  ];
}
