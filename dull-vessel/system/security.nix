{pkgs, ...}: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };
}
