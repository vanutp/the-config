{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];
  programs.ags = {
    enable = true;
    configDir = ./.;
  };
  systemd.user.services.ags.Install.WantedBy = lib.mkForce [];
}
