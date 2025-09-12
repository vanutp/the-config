{
  channel = "stable";
  system = ./system;
  users = {
    fox = {...}: {};
    root = {...}: {};
    lumi = ./lumi.nix;
  };
}
