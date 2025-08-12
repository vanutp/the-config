{
  self,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  sops-nix,
  ...
} @ inputs: hostname: let
  hostPath = ../hosts/${hostname};
  hostConfig = import ./getHostConfig.nix hostPath;
  pkgs = import nixpkgs {
    system = hostConfig.systemType;
    inherit overlays;
  };
  pkgs-unstable = import nixpkgs-unstable {
    system = hostConfig.systemType;
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
    inherit overlays;
  };
  args = {
    inherit self inputs hostname pkgs-unstable hostPath;
    self-pkgs = inputs.self.packages.${pkgs.system};
    systemConfig = null;
  };
  overlays = hostConfig.overlays inputs;
  mkSystemHM = hostConfig: [
    home-manager.nixosModules.home-manager
    ({config, ...}: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs =
          args
          // {
            mode = "home-bundled";
            systemConfig = config;
          };
        users =
          if hostname == "dull-vessel"
          then {root = hostConfig.users.root;}
          else hostConfig.users;
        sharedModules = [
          "${self}/utils/modules.nix"
        ];
      };
    })
  ];
  mkUserHM = hostConfig: username:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./modules.nix
        hostConfig.users.${username}
      ];
      extraSpecialArgs =
        args
        // {
          mode = "home-standalone";
        };
    };
in {
  nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
    system = hostConfig.systemType;
    modules =
      [
        {
          nixpkgs.overlays = overlays;
        }
        ../packages/veyon/module.nix
        sops-nix.nixosModules.sops
        inputs.disko.nixosModules.default
        hostConfig.system
        ./modules.nix
      ]
      ++ (mkSystemHM hostConfig);
    specialArgs =
      args
      // {
        mode = "system";
      };
  };
  homeConfigurations =
    if hostname == "dull-vessel"
    then
      builtins.listToAttrs
      (
        map
        (username: {
          name = "${username}@${hostname}";
          value = mkUserHM hostConfig username;
        })
        (builtins.attrNames (builtins.removeAttrs hostConfig.users ["root"]))
      )
    else {};
}
