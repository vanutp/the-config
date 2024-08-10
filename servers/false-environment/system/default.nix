{
  common,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    common.bundles.server.system
    ./hardware-configuration.nix
    ./disko.nix
    ./secrets.nix
  ];

  networking.hostName = "false-environment";

  time.timeZone = "Europe/Moscow";

  networking.wg-quick.interfaces = {
    wg0 = common.atoms.makeWg0 config {
      address = "10.1.0.6";
      isInternal = true;
      autostart = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  environment.systemPackages = with pkgs; [
    temurin-bin-17
    rdiff-backup
  ];
  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [443 24454];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * * fox rdiff-backup ~/server/world/ ~/backup/ 
                     && rdiff-backup --force remove increments --older-than 7D --size ~/backup/"
    ];
  };

  services.nginx = {
    enable = true;
    validateConfigFile = false;
    virtualHosts."mc.rightarion.ru" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www/mc.rightarion.ru/modpack";
        extraConfig = "autoindex on;";
      };
      locations."/launcher" = {
        alias = "/var/www/mc.rightarion.ru/launcher/";
        extraConfig = "autoindex on;";
      };
      locations."= /win".return = "302 /launcher/lumious_launcher.exe";
      locations."= /linux".return = "302 /launcher/lumious_launcher_linux";
      locations."= /macos".return = "302 /launcher/lumious_launcher_macos.dmg";
    };
    virtualHosts."map.rightarion.ru" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8100";
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "hello@vanutp.dev";
  };
  users.users.build = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      common.constants.pubkeys.main
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZ1H5VPM2JfkdR2NQvqnUdcwkosNpRSbP5l9sgL0RNcJj+CiWC6iygi7Ra3o84nUtIaTg/d2nofpK1dEiXkQoliPofdkJTxorRnAOYdegaAGT54N4R0KaYzsRJsPqMO+AsCTEz4BV2D6HEuyz8/Ht8aBsCctLCL+YeEjYF+mH2Rlz7NOuAvii9RnPsnpBDGGBAk25pPNW9qN3A97S85JrWlkScIxNhLpTfKU1uKioSHJjHd70MbJRdYHrSjwRbrrzHhOyza6OCezC0y0yeObqHoIT9uhRJ/bSeG1CTidZ+5/jc+OHVMQCfhQvsVfwnJnlv1g7iK/qtEmeoa4T4pv/iv3AqaoI9DgBvX7jJBg4fb7Gsmgod70aY5xW5ioPti0tAcUySLvOad+Cn1/sxRV4bnxY4waU/tTNQKxP0e4oGlS0Ypg9APbDFgP5r+Fk8ReWYoEynATTejevLbHIVQXSbydf1+78rleY1Iu5gPoU6bLH9GAl0TPYe/Bqr0mNAauE= dva-smp@s1"
    ];
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.podman.enable = lib.mkForce false;
  virtualisation.docker.enable = true;
  systemd.services.podman-restart.wantedBy = lib.mkForce [];
  users.extraGroups.docker.members = ["fox"];
  # portainer host module uses this
  system.activationScripts.traefik-create-data-dir.text = ''
    mkdir -p /usr/share/hwdata
    cp ${pkgs.hwdata}/share/hwdata/pci.ids /usr/share/hwdata/pci.ids
  '';
}
