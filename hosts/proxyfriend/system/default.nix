{...}: {
  imports = [
    ./containers
    ./mailcow.nix
    ./network.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./danted.nix
    ./wireguard.nix
  ];

  setup.computerType = "server";

  time.timeZone = "Europe/Moscow";

  vanutp.traefik = {
    enable = true;
    requestWildcardCertsFor = [
      "vanutp.dev"
    ];
    limits = {
      cpus = "1";
      memory = "0.5G";
    };
  };
  vanutp.maskman.enable = true;
}
