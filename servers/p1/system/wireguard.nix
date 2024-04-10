{config, ...}: {
  networking.wg-quick.interfaces = {
    wg0 = config.vanutp.makeWg0 {
      address = "10.1.3.1";
      isInternal = true;
      autostart = true;
    };
  };
}
