{
  channel = "stable";
  system = ./system;
  users = {
    fox = ./home;
    root = {common, ...}: {imports = [common.bundles.server.root];};
  };
  vars = ./vars.nix;
}
