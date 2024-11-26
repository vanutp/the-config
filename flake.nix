{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      # doesn't work with stable nixpkgs
      url = "github:nix-community/disko/4444751300a88d46c82aac6baaf4f1ea9c287830";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland.git?ref=refs/tags/v0.45.2&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces/131bc5bd02d7f558a66d1a6c4d0013d8545823e0";
      inputs.hyprland.follows = "hyprland";
    };
    manix = {
      url = "github:nix-community/manix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vhap-compose-update = {
      url = "git+https://foxlab.dev/vanutp/vhap-compose-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    pyproject-nix,
    hyprland,
    ...
  } @ inputs: let
    mkSystem = import ./utils/mkSystem.nix inputs;
    # https://stackoverflow.com/a/54505212
    recursiveMerge = with builtins;
      attrList: let
        f = attrPath:
          zipAttrsWith (
            n: values:
              if tail values == []
              then head values
              else if all isList values
              then unique (concatLists values)
              else if all isAttrs values
              then f (attrPath ++ [n]) values
              else last values
          );
      in
        f [] attrList;
    mkSystems = hostnames: recursiveMerge (map (hostname: mkSystem hostname) hostnames);
  in
    (mkSystems [
      "dull-vessel"
      "servers/sfer"
      "servers/p1"
      "servers/proxyfriend"
      "servers/embassy"
      "servers/collective"
    ])
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      packagesArgs = {inherit pkgs pkgs-unstable inputs;};
    in {
      formatter = pkgs.alejandra;
      packages = import ./packages packagesArgs;
      devShells.vhap = (import ./packages/vhap/pyproject.nix packagesArgs).shell;
    });
}
