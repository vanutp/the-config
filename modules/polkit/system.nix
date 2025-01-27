{
  lib,
  config,
  ...
}: {
  options = with lib; {
    security.polkit.serviceOwners = mkOption {
      description = "Mapping between system services and users that can manage them";
      type = with types; attrsOf str;
      default = {};
    };
  };
  config.security.polkit = let
    cfg = config.security.polkit;
  in {
    enable = lib.mkDefault config.setup.isLaptop;
    extraConfig = let
      hasServiceOwners = cfg.serviceOwners != {};
    in
      lib.optionalString
      (
        hasServiceOwners
        && lib.assertMsg (hasServiceOwners -> cfg.enable) "Service owners don't work without Polkit"
      ) ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-units") {
                var verb = action.lookup("verb");
                if (verb == "start" || verb == "stop" || verb == "restart") {
                    var service = action.lookup("unit").replace(/\.service$/, "");
                    var serviceOwners = ${builtins.toJSON cfg.serviceOwners};
                    if (subject.user == serviceOwners[service]) {
                        return polkit.Result.YES;
                    }
                }
            }
        });
      '';
  };
}
