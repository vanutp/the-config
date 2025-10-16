{...}: {
  # TODO: optional podman
  # it supports running systemd in container, which is useful for progtime
  virtualisation.oci-containers.backend = "docker";
  users.extraGroups.docker.members = ["fox"];
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      bip = "10.254.254.1/24";
      default-address-pools = [
        {
          base = "10.254.0.0/16";
          size = 28;
        }
      ];
      ipv6 = true;
      fixed-cidr-v6 = "fd00:dead:beef:c0::/80";
      experimental = true;
      live-restore = true;
    };
  };
}
