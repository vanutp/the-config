{
  config,
  pkgs,
  ...
}: {
  users.groups.ystalx = {};
  users.users.ystalx = {
    isNormalUser = true;
    group = "ystalx";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0pwg112MrUb6KAt+cfN+jqYw9jEBfhcmRnXpBOJMYq user@NewPC"
    ];
    linger = true;
  };

  users.groups.gravity_m = {};
  users.users.gravity_m = {
    isNormalUser = true;
    group = "gravity_m";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
      ""
    ];
    linger = true;
  };

  virtualisation.docker.rootless = {
    enable = true;
    daemon.settings.dns = ["1.1.1.1"];
  };

  networking.firewall.allowedTCPPorts = [25565 25575 25585];
  networking.firewall.allowedUDPPorts = [25566 25576];
}
