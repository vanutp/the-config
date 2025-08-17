{pkgs, ...}: {
  users.groups.ystalx = {};
  users.users.ystalx = {
    isNormalUser = true;
    group = "ystalx";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0pwg112MrUb6KAt+cfN+jqYw9jEBfhcmRnXpBOJMYq user@NewPC"
    ];
    linger = true;
  };
}
