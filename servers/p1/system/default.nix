{config, ...}: {
  imports = [
    ../../common/system.nix
    ./secrets.nix
    ./wireguard.nix
  ];

  networking.hostName = "p1";

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
