{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  users.extraGroups.podman.members = ["fox"];
  environment.systemPackages = with pkgs; [
    docker-client
  ];
  systemd.services.podman-restart.wantedBy = ["multi-user.target"];
}
