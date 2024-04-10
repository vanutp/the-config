{config, ...}: {
  imports = [
    ../../common/system.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ./wireguard.nix
    ./postgresql.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "p1";
  # nixos networkd module doesn't allow to add onlink default gateway
  # and doesn't allow to add regular routes without Destination
  # plus i don't really want to commit plaintext server ips to the repo
  sops.templates."network.conf" = {
    content = ''
      [Match]
      Name=ens3

      [Network]
      Address=${config.sops.placeholder.host-ip}/32
      DNS=1.1.1.1

      [Route]
      Gateway=2a01:230:4:1ea::1
      Gateway=10.0.0.1
      GatewayOnLink=yes
    '';
    mode = "0644";
  };
  environment.etc."systemd/network/main.network".source = config.sops.templates."network.conf".path;

  time.timeZone = "Europe/Moscow";

  services.vhap-compose-update = {
    enable = true;
    user = "fox";
    group = "users";
    port = 8001;
    baseDir = "/home/fox/containers";
    logsDir = "/home/fox/vhap-compose-update-logs";
    entries = [
      {
        key = config.sops.placeholder."vhap-compose-update/progtime";
        service = "progtime";
      }
    ];
  };

  # disable nsdelegate to be able to pass cgroup dir to podman container
  fileSystems."/sys/fs/cgroup" = {
    fsType = "cgroup2";
    device = "cgroup2";
    options = ["nosuid" "nodev" "noexec" "memory_recursiveprot"];
  };
}
