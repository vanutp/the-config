{
  pkgs,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [25 465 587 143 993 110 995 4190];

  vanutp.backup.backups.mailcow = let
    target-dir = "/tmp/mailcow-backup";
    mailcow-dir = "/home/fox/mailcow";
  in {
    # TODO: make sure backup dir doesn't exist beforehand to avoid uploading old data
    backupPrepareCommand = ''
      mkdir ${target-dir}
      chmod 700 ${target-dir}
      export PATH=${lib.makeBinPath (with pkgs; [docker bash which])}:$PATH
      env MAILCOW_BACKUP_LOCATION=${target-dir} ${mailcow-dir}/helper-scripts/backup_and_restore.sh backup all --delete-days 1
      [ -f ${target-dir}/mailcow-*/backup_vmail.tar.gz ] || {
        echo "Backup files do not exist"
        exit 1
      }
    '';
    # insert text
    dynamicFilesFrom = ''
      files=(${target-dir}/mailcow-*)
      echo "$files"
    '';
    extraBackupArgs = ["--compression=off"];
    backupCleanupCommand = "rm -rf ${target-dir}";
  };
  # mailcow backup script mounts target dir into docker, which uses real /tmp
  systemd.services.restic-backups-mailcow.serviceConfig.PrivateTmp = lib.mkForce false;
}
