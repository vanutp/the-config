{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.uwsm = {
    enable = true;
    waylandCompositors.default = {
      prettyName = "Default";
      comment = "Default user session";
      binPath = pkgs.writeScript "default-session.sh" ''
        #!${pkgs.runtimeShell}
        exec default-user-session
      '';
    };
  };

  services.greetd = let
    uwsm = lib.getExe config.programs.uwsm.package;
  in {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.tuigreet} --cmd \"${uwsm} start default\"";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [libsecret];
  programs.seahorse.enable = true;
  services.dbus.packages = with pkgs; [gcr];
}
