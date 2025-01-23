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
    inherit self inputs hostname pkgs-unstable;
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
            mode = "home";
            systemConfig = config;
          };
        users = hostConfig.users;
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
          mode = "home";
        };
    };
in
  assert builtins.elem hostConfig.hmMode ["monolith" "modular"]; {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = hostConfig.systemType;
      modules =
        [
          {
            nixpkgs.overlays = overlays;
          }
          ../packages/veyon/module.nix
          sops-nix.nixosModules.sops
          {
            sops = {
              defaultSopsFile = "${hostPath}/system/secrets.yml";
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
            };
          }
          hostConfig.system
          ./modules.nix
        ]
        ++ (
          if hostConfig.hmMode == "monolith"
          then mkSystemHM hostConfig
          else []
        );
      specialArgs =
        args
        // {
          mode = "system";
        };
    };
    homeConfigurations =
      if hostConfig.hmMode == "modular"
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
  }
