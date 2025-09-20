{
  channel = "stable";
  system = ./system;
  users = {
    fox = {...}: {};
    root = {...}: {};
    ystalx = ./ystalx.nix;
  };
}
