{
  config,
  pkgs,
  ...
}: {
  _module.args.util = {
    mkWg0 = import ./mkWg0.nix config;
  };
}
