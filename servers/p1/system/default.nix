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
}
