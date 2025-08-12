{config, ...}: let
  dataDir = "/srv/media";
in {
  systemd.tmpfiles.settings.media-server."/srv/media".d = {
    user = "fox";
    group = "1000";
    mode = "0770";
  };
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /srv/media 100.111.249.84(rw,nohide,insecure,no_subtree_check,no_root_squash)
    '';
  };
  networking.firewall = {
    allowedTCPPorts = [2049 4000 4001 4002];
    allowedUDPPorts = [2049 4000 4001 4002];
  };

  virtualisation.composter.apps.media_server = let
    linuxserverEnv = {
      PGID = "1000";
      PUID = "1000";
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
        image = "lscr.io/linuxserver/qbittorrent:latest";
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
          "${dataDir}:/media"
        ];
      };
    };
  };
}
