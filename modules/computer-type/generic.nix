{
  config,
  lib,
  systemConfig,
  ...
}: let
  cfg = config.setup.computerType;
in {
  options.setup = let
    inherit (lib) mkOption types;
  in {
    computerType = mkOption {
      description = "Type of computer that the configuration is for.";
      type = types.enum ["laptop" "server"];
      readOnly = systemConfig != null;
    };
    isServer = mkOption {
      description = "Whether the computer is a server.";
      type = types.bool;
      readOnly = true;
    };
    isLaptop = mkOption {
      description = "Whether the computer is a laptop.";
      type = types.bool;
      readOnly = true;
    };
  };
  config = lib.mkMerge [
    {
      setup.isServer = cfg == "server";
      setup.isLaptop = cfg == "laptop";
    }
    (lib.optionalAttrs (systemConfig != null) {
      setup.computerType = systemConfig.setup.computerType;
    })
  ];
}
