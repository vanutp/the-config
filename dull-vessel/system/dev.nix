{pkgs, ...}: {
  services.redis.servers.main = {
    enable = true;
    port = 6379;
  };
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  users.extraGroups.podman.members = ["fox"];
  services.postgresql = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    docker-client
  ];
  virtualisation.virtualbox = {
    host.enable = true;
    # host.enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = ["fox"];

  nix.settings = {
    trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
    substituters = ["https://devenv.cachix.org"];
  };

  environment.etc."mime.types".source = "${pkgs.mime-types}/etc/mime.types";
}
