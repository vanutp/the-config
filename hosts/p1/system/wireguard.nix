{
  self,
  config,
  ...
}: {
  networking.wg-quick.interfaces = let
    makeWg0 = import "${self}/utils/makeWg0.nix";
  in {
    wg0 = makeWg0 config {
      address = "10.1.3.1";
      isInternal = true;
      autostart = true;
    };
  };
}
