{
  channel = "stable";
  system = ./system;
  users = {
    fox = {...}: {};
    root = {...}: {};
    gravity_m = import ./gravity_m.nix;
  };
}
