pkgs: {
  # TODO: generate this automatically
  bundles = {
    fox = ./bundles/fox;
    root = ./bundles/root;
    system = ./bundles/system;

    server = {
      fox = ./bundles/server/fox;
      root = ./bundles/server/root.nix;
      system = ./bundles/server/system.nix;
    };
  };
  atoms = {
    makeWg0 = import ./atoms/makeWg0.nix;
  };
  blocks = {
    nix-settings = import ./blocks/nix-settings.nix;
    vds-networking = import ./blocks/vds-networking.nix;
    progtime = import ./blocks/progtime.nix;
    traefik = import ./blocks/traefik.nix;
  };
  composter = import ./composter.nix;
  utils = import ./utils/utils.nix pkgs;
  constants = import ./constants.nix;
}
