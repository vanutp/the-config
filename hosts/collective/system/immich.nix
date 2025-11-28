{...}: let
  immich-port = 8001;
  media-dir = "/srv/immich";
in {
  fileSystems."${media-dir}" = {
    device = "memory-hole:${media-dir}";
    fsType = "nfs";
  };
  vanutp.backup.backups.immich = {
    paths = [media-dir];
    exclude = [
      "${media-dir}/backups"
      "${media-dir}/encoded-video"
      "${media-dir}/thumbs"
    ];
    schedule = "*-*-* 03:00:00";
  };

  systemd.services.immich-server = {
    requires = ["srv-immich.mount"];
    after = ["srv-immich.mount"];
  };
  services.immich = {
    enable = true;
    mediaLocation = media-dir;
    port = immich-port;
  };

  vanutp.traefik.proxies = [
    {
      host = "photos.vanutp.dev";
      target = "http://localhost:${builtins.toString immich-port}";
    }
  ];

  vanutp.gatus.checks.immich = {
    url = "https://photos.vanutp.dev/api/server/ping";
    conditions = [
      "[STATUS] == 200"
      "[BODY].res == pong"
    ];
  };
}
