{pkgs, ...}: {
  virtualisation.podman.dockerSocket.enable = true;
  users.extraGroups.podman.members = ["fox"];
  environment.systemPackages = with pkgs; [
    docker-client
  ];
}
