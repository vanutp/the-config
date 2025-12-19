{
  config,
  pkgs,
  ...
}: {
  users.groups.ystalx = {};
  users.users.ystalx = {
    isNormalUser = true;
    group = "ystalx";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0pwg112MrUb6KAt+cfN+jqYw9jEBfhcmRnXpBOJMYq user@NewPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh9HC1OjynYLLTGYYGsOkTR5NJjivq05ySxuUt3iGu/ onmyd@onmydy"
    ];
    linger = true;
  };
  users.groups.lumi = {};
  users.users.lumi = {
    isNormalUser = true;
    group = "lumi";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+4xbwlGaSNKTcw1VRz7dPH7BWi8f+YSBa/ZTYqxfTv"
    ];
    linger = true;
  };
}
