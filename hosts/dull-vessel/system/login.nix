{
  pkgs,
  lib,
  ...
}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.greetd.tuigreet} --cmd \"zsh -l -c 'Hyprland'\"";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  environment.systemPackages = with pkgs; [libsecret];
  programs.seahorse.enable = true;
}
