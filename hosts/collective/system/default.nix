{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./containers
    ./gitlab.nix
    ./hardware-configuration.nix
    ./immich
    ./network.nix
    ./postgresql.nix
    ./tgpy_redirect.nix
    ./traefik.nix
    ./wireguard.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  time.timeZone = "Europe/Berlin";

  boot.swraid.mdadmConf =
    "PROGRAM "
    + pkgs.writeShellScript "mdadmNotify" ''
      if [[ $1 == "NewArray" ]]; then
        exit 0
      fi
      token=$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."bot_token".path})
      ${lib.getExe pkgs.curl} -s https://api.telegram.org/bot$token/sendMessage \
        --data-urlencode "chat_id=-1001212850694" \
        --data-urlencode "text=mdmon alert: $@"
    '';

  programs.mosh.enable = true;

  setup.computerType = "server";

  systemd.network.wait-online.enable = false;

  vanutp.backup = {
    enable = true;
    remotes = {
      default.path = "s3:https://s3.eu-central-003.backblazeb2.com/collective-backup";
      hetzner = {
        path = "rclone:backup_hetzner_fin:backup";
        rcloneConfig = {
          type = "sftp";
          host = "u478967.your-storagebox.de";
          user = "u478967";
          key_file = config.sops.secrets."restic/hetzner/ssh-key".path;
        };
      };
    };
  };
  programs.ssh.knownHosts."u478967.your-storagebox.de".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";

  # speech-cabinet crashes frequently
  systemd.coredump.extraConfig = "Storage=none";
}
