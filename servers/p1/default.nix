{
  channel = "stable";
  system = ./system;
  users = {
    fox = ../common/fox;
    root = ../common/root.nix;
  };
}
