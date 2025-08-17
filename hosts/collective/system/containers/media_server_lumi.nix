{
  config,
  lib,
  pkgs,
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
        env_file = config.sops.secrets."media_server_lumi".path;
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
        restart = "always";
      };
      requester_nginx = {
        image = "registry.vanutp.dev/vanutp/media-server/nginx";
        restart = "always";
        labels = {
          "traefik.http.routers.watch__rightarion__ru.tls.certresolver" = "http";
        };
        traefik = {
          host = "watch.rightarion.ru";
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
