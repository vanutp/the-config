{
  lib,
  config,
  pkgs,
  ...
}: {
  options = with lib; {
    # TODO: make proper options
    virtualisation.composter = {
      services = mkOption {
        type = types.attrsOf types.anything;
        default = {};
      };
    };
  };

  imports = [
    {
      virtualisation.podman.enable = true;
      systemd.services.podman-restart.wantedBy = ["multi-user.target"];
      networking.firewall.interfaces."podman+".allowedUDPPorts = [53];
    }
  ];

  config = let
    podman = lib.getExe pkgs.podman;
    serviceToContainers = serviceName: serviceConfig:
      lib.mapAttrs'
      (containerName: containerConfig: {
        name = "${serviceName}-${containerName}";
        value =
          (builtins.removeAttrs containerConfig ["traefik"])
          // {
            extraOptions =
              (containerConfig.extraOptions or [])
              ++ [
                "--network=${serviceName}"
                "--network-alias=${containerName}"
              ];
            dependsOn = map (x: "${serviceName}-${x}") (containerConfig.dependsOn or []);
            labels =
              (containerConfig.labels or {})
              // (
                if containerConfig ? traefik
                then let
                  host = containerConfig.traefik.host;
                  entryId = builtins.replaceStrings ["."] ["__"] host;
                in {
                  "traefik.enable" = "true";
                  "traefik.http.routers.${entryId}.rule" = "Host(`${host}`)";
                }
                else {}
              );
          };
      })
      serviceConfig;
    appToNetwork = appName: appConfig: {
      name = "composter-${appName}-network";
      value = let
        dependents = map (containerName: "podman-${appName}-${containerName}.service") (builtins.attrNames appConfig);
      in {
        requiredBy = dependents;
        before = dependents;
        script = ''
          ${podman} network exists ${appName} || ${podman} network create ${appName}
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${podman} network rm ${appName}";
        };
      };
    };
  in {
    virtualisation.oci-containers.containers = lib.concatMapAttrs serviceToContainers config.virtualisation.composter.services;
    systemd.services = lib.mapAttrs' appToNetwork config.virtualisation.composter.services;
  };
}
