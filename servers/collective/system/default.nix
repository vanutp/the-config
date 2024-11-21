{
  common,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    ./containers
    ./hardware-configuration.nix
    ./postgresql.nix
    ./secrets.nix
    ./wireguard.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  networking.hostName = "collective";

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
}
