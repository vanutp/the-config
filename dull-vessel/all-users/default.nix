{pkgs, ...}: {
  imports = [
    ../../common/all-users
  ];

  home.packages = with pkgs; [
    ventoy-full
  ];
}
