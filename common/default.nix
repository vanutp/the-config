pkgs: {
  bundles = {
    fox = ./bundles/fox;
    root = ./bundles/root;
    all-users = ./bundles/all-users;
    system = ./bundles/system;

    server = {
      fox = ./bundles/server/fox;
      root = ./bundles/server/root.nix;
      system = ./bundles/server/system.nix;
    };
  };
  utils = import ./utils.nix pkgs;
}
