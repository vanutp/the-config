{
  channel = "stable";
  system = ./system;
  users = {
    fox = {common, ...}: {imports = [common.bundles.server.fox];};
    root = {common, ...}: {imports = [common.bundles.server.root];};
    gravity_m = import ./gravity_m.nix;
  };
  vars = ./vars.nix;
}
