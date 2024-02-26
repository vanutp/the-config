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
}
