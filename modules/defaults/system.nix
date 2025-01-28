{
  config,
  hostname,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./system-server.nix
  ];

  # Never change this
  system.stateVersion = "24.05";

  networking.hostName = hostname;

  time.timeZone = lib.mkDefault "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  users.users.fox = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.setup.pubkeys.main
    ];
    linger = true;
  };
}
