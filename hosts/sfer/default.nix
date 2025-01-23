{
  channel = "stable";
  system = ./system.nix;
  users = {
    fox = {...}: {};
    root = {...}: {};
  };
}
