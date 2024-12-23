{
  pkgs,
  inputs,
  lib,
  common,
  ...
}: {
  # Never change this
  system.stateVersion = "24.05";

  imports = [
    (common.blocks.nix-settings false)
    common.composter
    ./security.nix
    inputs.vhap-compose-update.nixosModules.default
  ];

  time.timeZone = lib.mkDefault "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  programs.zsh.enable = true;
  users.users.fox = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      common.constants.pubkeys.main
    ];
    linger = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
