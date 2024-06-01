{
  common,
  config,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = common.atoms.makeWg0 config {
      address = "10.1.3.1";
      isInternal = true;
      autostart = true;
    };
  };
}
