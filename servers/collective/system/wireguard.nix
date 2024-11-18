{
  common,
  config,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = common.atoms.makeWg0 config {
      address = "10.1.0.6";
      isInternal = true;
      autostart = true;
    };
  };
}
