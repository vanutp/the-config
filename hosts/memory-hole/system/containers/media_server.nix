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
          host = "qbittorrent.vanutp.dev";
          port = 8080;
          proxied = false;
        };
        environment = linuxserverEnv;
        volumes = [
          "./configs/qbittorrent:/config"
          "${cfg.path}:/media"
        ];
      };
    };
  };
}
