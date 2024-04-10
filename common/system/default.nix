{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Never change this
  system.stateVersion = "24.05";

  imports = [
    ./utils.nix
    ./podman.nix
    ./security.nix
    inputs.vhap-compose-update.nixosModules.default
  ];

  # breaks podman dns :(
  networking.firewall.enable = false;

  time.timeZone = lib.mkDefault "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes" "repl-flake"];
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  users.users.fox = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      config.vanutp.pubkeys.main
    ];
  };

  programs.nix-ld.enable = true;
}