{
  lib,
  config,
  ...
}: {
  options = {
    systemd.user.sessionServices = lib.mkOption {
      description = "List of services to run at `graphical-session.target`";
      type = lib.types.listOf (lib.types.submodule ({config, ...}: {
        options = {
          package = lib.mkOption {
            description = "Package to create service for";
            type = lib.types.package;
          };
          name = lib.mkOption {
            description = "Name of the service";
            type = lib.types.str;
            default = config.package.name;
          };
          binary = lib.mkOption {
            description = "Path to the binary to run relative to package root";
            type = lib.types.str;
            example = "/libexec/hyprpolkitagent";
            default = "/bin/${config.package.meta.mainProgram}";
          };
          args = lib.mkOption {
            description = "List of arguments to pass to the program";
            type = with lib.types; listOf str;
            default = [];
          };
        };
      }));
      default = [];
    };
  };
  config = {
    systemd.user.services = lib.listToAttrs (
      lib.map
      (service: let
        target = "graphical-session.target";
      in {
        name = service.name;
        value = {
          Unit = {
            Description = service.package.name;
            PartOf = target;
            After = target;
            Requisite = target;
          };
          Service = {
            ExecStart = "${service.package}${service.binary} ${lib.concatStringsSep " " service.args}";
            Restart = "on-failure";
          };
          Install = {
            WantedBy = [target];
          };
        };
      })
      config.systemd.user.sessionServices
    );
  };
}
