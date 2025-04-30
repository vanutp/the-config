{
  config,
  pkgs,
  lib,
  ...
}: let
  immich-port = 8001;
  redis-port = 6380;
  media-dir = "/srv/immich";
  volume-name = "immich-media";
  bucket-url = "https://s3.eu-central-003.backblazeb2.com/collective-immich";
in {
  sops.secrets."immich/fs" = {};
  services.redis.servers.immich-fs = {
    enable = true;
    appendOnly = true;
    port = redis-port;
  };
  # TODO: run juicefs compact
  systemd.services.immich-fs = let
    juicefs = lib.getExe' pkgs.juicefs "juicefs";
    redis-url = "redis://127.0.0.1:${builtins.toString redis-port}";
  in {
    after = ["network.target" "redis-immich-fs.service"];
    requires = ["redis-immich-fs.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."immich/fs".path;
    };
    preStart = ''
      mkdir -p ${media-dir}
      chown -R immich:immich ${media-dir}
      ${juicefs} status ${redis-url} \
        || ${juicefs} format \
           --storage s3 \
           --bucket ${bucket-url} \
           --encrypt-rsa-key ${./fs-key.pem} \
           --trash-days 0 \
           ${redis-url} ${volume-name}
    '';
    # TODO: use systemd.mount?
    script = "${juicefs} mount ${redis-url} ${media-dir}";
  };

  vanutp.backup.backups.immich-fs = {
    backupPrepareCommand = ''
      ${lib.getExe' pkgs.redis "redis-cli"} \
        -p ${builtins.toString redis-port} \
        SAVE
    '';
    paths = ["/var/lib/redis-immich-fs/dump.rdb"];
    schedule = "*-*-* 03:00:00";
  };

  systemd.services.immich-server = {
    requires = ["immich-fs.service"];
    after = ["immich-fs.service"];
  };
  systemd.services.immich-machine-learning = {
    # idk if this is needed for machine-learning service
    requires = ["immich-fs.service"];
    after = ["immich-fs.service"];
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
}
