{...}: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.pcscd.enable = true;
}
