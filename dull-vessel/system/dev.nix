{pkgs, ...}: {
  services.redis.servers.main = {
    enable = true;
    port = 6379;
  };
  services.postgresql = {
    enable = true;
  };

  services.minio.enable = true;

  virtualisation.virtualbox = {
    host.enable = true;
    # host.enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = ["fox"];

  virtualisation.vmware.host.enable = true;

  nix.settings = {
    trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
    substituters = ["https://devenv.cachix.org"];
  };

  environment.etc."mime.types".source = "${pkgs.mime-types}/etc/mime.types";

  boot.binfmt = {
    emulatedSystems = ["aarch64-linux"];
    registrations.aarch64-linux.fixBinary = true;
    registrations.aarch64-linux.openBinary = true;
  };

  networking.firewall.interfaces.int.allowedTCPPorts = [7000 7001];

  services.nginx = {
    enable = true;
    validateConfigFile = false;
    virtualHosts."minecraft.local" = {
      locations."/" = {
        root = "/var/www/minecraft.local";
        extraConfig = "autoindex on;";
      };
      locations."/auth" = {
        proxyPass = "http://10.1.1.2:7000";
      };
    };
  };
  networking.extraHosts = "127.0.0.1 minecraft.local";
}
