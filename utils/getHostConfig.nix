(hostPath: let
  hostConfig = import hostPath;
in {
  systemType = hostConfig.systemType or "x86_64-linux";
  overlays = hostConfig.overlays or (inputs: []);
  inherit (hostConfig) system users;
})
