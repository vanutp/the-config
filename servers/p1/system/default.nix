{
  common,
  config,
  pkgs,
  ...
}: {
  imports = [
    common.bundles.server.system
    common.blocks.vds-networking
    ./traefik.nix
    ./containers
    ./hardware-configuration.nix
    ./secrets.nix
    ./wireguard.nix
    ./postgresql.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "p1";

  time.timeZone = "Europe/Moscow";

  services.vhap-compose-update = {
    enable = true;
    user = "root";
    group = "root";
    port = 8001;
    baseDir = "/srv/vhap";
    logsDir = "/srv/vhap/_vhap_update_logs";
    entries = [
      {
        key = config.sops.placeholder."vhap-compose-update/progtime";
        service = "my_progtime_net";
      }
    ];
  };

  # disable nsdelegate to be able to pass cgroup dir to podman container
  # TODO: is this needed for docker too?
  fileSystems."/sys/fs/cgroup" = {
    fsType = "cgroup2";
    device = "cgroup2";
    options = ["nosuid" "nodev" "noexec" "memory_recursiveprot"];
  };

  users.users.fox.openssh.authorizedKeys.keys = [
    common.constants.pubkeys.embassy
  ];
  users.users.apocalypse = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.bash;
  };
}
