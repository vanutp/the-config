{pkgs, ...}: let
  nerdfonts' = pkgs.nerdfonts.override {
    fonts = ["FiraCode" "JetBrainsMono"];
  };
in {
  # zed can't see home-manager fonts
  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    fira
    fira-math
    nerdfonts'
  ];
}
