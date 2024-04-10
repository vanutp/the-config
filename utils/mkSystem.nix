({
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  } @ inputs: hostPath: let
    hostname = builtins.baseNameOf hostPath;
    hostConfig = import ./getHostConfig.nix hostPath;
    args = {inherit inputs;};
    overlays = hostConfig.overlays inputs;
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
          inherit overlays;
        };
        modules = [hostConfig.users.${username}];
        extraSpecialArgs = args;
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
                defaultSopsFile = ../${hostPath}/system/secrets.yml;
                age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              };
            }
            hostConfig.system
          ]
          ++ (
            if hostConfig.hmMode == "monolith"
            then mkSystemHM hostConfig
            else []
          );
        specialArgs = args;
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
    })
