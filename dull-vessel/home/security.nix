{pkgs, ...}: {
  home.packages = with pkgs; [
    yubikey-manager
    age
    ssh-to-age
    sops
  ];
}
