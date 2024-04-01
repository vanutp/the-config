{pkgs, ...}: {
  # breaks video playback in telegram and mpv for some reason
  #security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alsa-firmware
    sof-firmware
  ];
}
