{
  pkgs,
  lib,
  ...
}: let
  hyprlandConfig = pkgs.writeText "greetd-hyprland-config" ''
    exec-once=${lib.getExe pkgs.greetd.gtkgreet} -l; hyprctl dispatch exit
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.hyprland} -c ${hyprlandConfig}";
      };
    };
  };
  environment.etc."greetd/environments".text = ''
    zsh -l -c 'Hyprland'
    zsh
  '';

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  environment.systemPackages = with pkgs; [libsecret];
  programs.seahorse.enable = true;
}
