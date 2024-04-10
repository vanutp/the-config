{pkgs, ...}: {
  imports = [
    ../../../common/all-users
    ../../../common/fox
    ./shell.nix
  ];

  home.packages = with pkgs; [
    pgcli
  ];
}
