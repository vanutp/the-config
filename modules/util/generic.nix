{
  config,
  pkgs,
  ...
}: {
  _module.args.util = {
    mkWg0 = import ./mkWg0.nix config;
    readYaml = import ./readYaml.nix pkgs;
  };
}
