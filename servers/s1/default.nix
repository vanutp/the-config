{
  channel = "stable";
  system = ./system.nix;
  users = {
    fox = {common, ...}: {imports = [common.bundles.server.fox];};
    root = {common, ...}: {imports = [common.bundles.server.root];};
  };
  vars = ./vars.nix;
}
