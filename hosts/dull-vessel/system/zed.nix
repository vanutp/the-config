{pkgs, ...}: {
  # zed can't see home-manager fonts
  # TODO: replace with fonts.packages
  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    fira
    fira-math
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
