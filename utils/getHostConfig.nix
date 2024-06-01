(hostPath: let
  hostRoot = ../${hostPath};
  hostConfig = import hostRoot;
in {
  systemType = hostConfig.systemType or "x86_64-linux";
  hmMode = hostConfig.hmMode or "monolith";
  overlays = hostConfig.overlays or (inputs: []);
  inherit (hostConfig) system users;
  vars = import hostConfig.vars;
})
