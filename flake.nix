{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #catppuccin.url = "github:catppuccin/nix";
    catppuccin.url = "github:Stonks3141/ctp-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.35.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces/2b1abdbf9e9de9ee660540167c8f51903fa3d959";
      inputs.hyprland.follows = "hyprland";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    manix = {
      url = "github:nix-community/manix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    sops-nix,
    flake-utils,
    ...
  } @ inputs: let
    mkSystem = hostname: let
      args = {inherit inputs;};
      hostConfig = import ./${hostname} inputs;
      hmMode = hostConfig.hmMode or "monolith";
      mkSystemHM = hostConfig: [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = args;
            users = hostConfig.users;
          };
        }
      ];
      mkUserHM = hostConfig: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = hostConfig.systemType;
            overlays = hostConfig.overlays;
          };
          modules = [hostConfig.users.${username}];
          extraSpecialArgs = args;
        };
    in
      assert builtins.elem hmMode ["monolith" "modular"]; {
        nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
          system = hostConfig.systemType;
          modules =
            [
              {
                nixpkgs.overlays = hostConfig.overlays;
              }
              ./packages/veyon/module.nix
              sops-nix.nixosModules.sops
              {
                sops = {
                  defaultSopsFile = ./${hostname}/system/secrets.yml;
                  age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
                };
              }
              hostConfig.system
            ]
            ++ (
              if hmMode == "monolith"
              then mkSystemHM hostConfig
              else []
            );
          specialArgs = args;
        };
        homeConfigurations =
          if (hostConfig.hmMode or "monolith") == "modular"
          then
            builtins.listToAttrs
            (
              map
              (username: {
                name = "${username}@${hostname}";
                value = mkUserHM hostConfig username;
              })
              (builtins.attrNames hostConfig.users)
            )
          else {};
      };
    mkSystems = hostnames:
      builtins.zipAttrsWith
      (name: values: assert builtins.length values == 1; builtins.elemAt values 0)
      (map (hostname: mkSystem hostname) hostnames);
  in
    (mkSystems [
      "dull-vessel"
    ])
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter = pkgs.alejandra;
      packages = import ./packages {inherit pkgs;};
    });
}
