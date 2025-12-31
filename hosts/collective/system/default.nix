{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./containers
    ./elasticsearch.nix
    ./gatus.nix
    ./gitlab
    ./hardware-configuration.nix
    ./immich.nix
    ./network.nix
    ./postgresql.nix
    ./tgpy_redirect.nix
    ./traefik.nix
    ./users.nix
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
        --data-urlencode "text=collective mdmon alert: $@"
    '';

  programs.mosh.enable = true;

  setup.computerType = "server";

  systemd.network.wait-online.enable = false;

  vanutp.backup = {
    enable = true;
    remotes.default.path = "s3:https://s3.eu-central-003.backblazeb2.com/collective-backup";
  };

  # speech-cabinet crashes frequently
  systemd.coredump.extraConfig = "Storage=none";
}
