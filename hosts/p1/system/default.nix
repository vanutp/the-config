{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./traefik.nix
    ./containers
    ./hardware-configuration.nix
    ./network.nix
    ./secrets.nix
    ./wireguard.nix
    ./postgresql.nix
  ];

  setup.computerType = "server";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  time.timeZone = "Europe/Moscow";

  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/progtime";
      services = ["my_progtime_net"];
    }
  ];

  # disable nsdelegate to be able to pass cgroup dir to podman container
  # TODO: is this needed for docker too?
  fileSystems."/sys/fs/cgroup" = {
    fsType = "cgroup2";
    device = "cgroup2";
    options = ["nosuid" "nodev" "noexec" "memory_recursiveprot"];
  };

  users.users.fox.openssh.authorizedKeys.keys = [
    config.setup.pubkeys.embassy
  ];
  users.users.apocalypse = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.bash;
  };
}
