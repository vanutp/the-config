{pkgs, ...}: {
  # breaks video playback in telegram and mpv for some reason
  #security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."bt-combined" = {
      "context.modules" = [
        {
          name = "libpipewire-module-combine-stream";
          args = {
            "combine.mode" = "sink";
            "node.name" = "bt_broadcast";
            "node.description" = "A combined sink to all bluetooth devices";
            "combine.latency-compensate" = false;
            "combine.props" = {
              "audio.position" = ["FL" "FR"];
            };
            "stream.props" = {};
            "stream.rules" = [
              {
                matches = [
                  {
                    "node.name" = "~bluez_output.*";
                    "media.class" = "Audio/Sink";
                  }
                ];
                actions = {
                  create-stream = {
                  };
                };
              }
            ];
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-firmware
    sof-firmware
  ];
}
