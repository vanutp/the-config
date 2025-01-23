{
  self,
  config,
  ...
}: let
  makeWg0 = import "${self}/utils/makeWg0.nix";
in {
  networking.wg-quick.interfaces = {
    wg0 = makeWg0 config {
      address = "10.1.0.6";
      isInternal = true;
      autostart = true;
    };
  };
}
