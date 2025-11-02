{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = ''
      # TYPE  DATABASE  USER  ADDRESS     METHOD
      host    all       all   0.0.0.0/0  scram-sha-256
    '';
    extensions = ps:
      with ps; [
        pgvector
      ];
    settings = {
      shared_buffers = "256MB";
      max_connections = 300;
    };
  };
  networking.firewall.allowedTCPPorts = [5432];

  vanutp.backup.backups.postgres = {
    backupPrepareCommand = ''
      export PATH=${config.services.postgresql.package}/bin:${pkgs.zstd}/bin:$PATH
      /run/wrappers/bin/sudo -u postgres pg_dumpall | zstd -T4 > /tmp/postgres.sql.zst
    '';
    paths = ["/tmp/postgres.sql.zst"];
    extraBackupArgs = ["--compression=off"];
    backupCleanupCommand = "rm /tmp/postgres.sql.zst";
    schedule = "*-*-* 03:00:00";
  };
}
