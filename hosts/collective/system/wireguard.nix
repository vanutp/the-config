{
  config,
  util,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = util.mkWg0 {
      address = "10.1.0.6";
      isInternal = true;
      autostart = true;
    };
  };
}
