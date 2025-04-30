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
    ./minecraft-gravity_m.nix
    ./minecraft.nix
    ./network.nix
    ./postgresql.nix
    ./secrets.nix
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

  programs.fish.enable = true;
  users.users.liferooter = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqqape1/IJC8PK+7lJxwM9N9Oo4SK7HZ7SnCMZjmaTR liferooter@computer"
    ];
  };
  networking.firewall.allowedTCPPorts = [25556];
  networking.firewall.allowedUDPPorts = [24456];

  systemd.network.wait-online.enable = false;

  vanutp.backup = {
    enable = true;
    s3-url = "https://s3.us-east-005.backblazeb2.com/backup-collective";
  };

  # speech-cabinet crashes frequently
  systemd.coredump.extraConfig = "Storage=none";
}
