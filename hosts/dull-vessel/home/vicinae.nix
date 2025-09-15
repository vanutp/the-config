{
  inputs,
  lib,
  pkgs,
  ...
}: let
  vicinae = inputs.vicinae.packages.${pkgs.system}.default;
in {
  home.packages = [
    vicinae
  ];
  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae server daemon";
      Documentation = ["https://docs.vicinae.com"];
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      BindsTo = ["graphical-session.target"];
    };
    Service = {
      Environment = ["USE_LAYER_SHELL=1"];
      Type = "simple";
      ExecStart = "${lib.getExe vicinae} server";
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
