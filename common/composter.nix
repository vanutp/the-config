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
        type = types.attrsOf (types.submodule {
          options = {
            containers = mkOption {
              type = types.attrsOf types.anything;
            };
            network = {
              ipv4 = {
                subnet = mkOption {type = types.nullOr types.str;};
              };
              ipv6 = {
                # TODO: add constraints
                enable = mkOption {
                  type = types.bool;
                  default = false;
                };
                subnet = mkOption {type = types.nullOr types.str;};
              };
            };
          };
        });
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
          (builtins.removeAttrs containerConfig ["traefik" "network"])
          // {
            extraOptions =
              (containerConfig.extraOptions or [])
              ++ (
                if (containerConfig ? network)
                then ["--network=${containerConfig.network}"]
                else [
                  "--network=${serviceName}"
                  "--network-alias=${containerName}"
                ]
              );
            dependsOn = map (x: "${serviceName}-${x}") (containerConfig.dependsOn or []);
            labels =
              (containerConfig.labels or {})
              // {
                "com.docker.compose.project" = serviceName;
                "com.docker.compose.service" = containerName;
              }
              // (
                if containerConfig ? traefik
                then let
                  entry = containerConfig.traefik;
                  entryId = builtins.replaceStrings ["."] ["__"] entry.host;
                in
                  {
                    "traefik.enable" = "true";
                    "traefik.http.routers.${entryId}.rule" = "Host(`${entry.host}`)";
                  }
                  // (
                    if entry ? port
                    then {
                      "traefik.http.services.${entryId}.loadbalancer.server.port" = builtins.toString entry.port;
                    }
                    else {}
                  )
                else {}
              );
          };
      })
      serviceConfig.containers;
    serviceToNetwork = serviceName: serviceConfig: {
      name = "composter-${serviceName}-network";
      value = let
        dependents = map (containerName: "podman-${serviceName}-${containerName}.service") (builtins.attrNames serviceConfig.containers);
        netCfg = serviceConfig.network;
      in {
        requiredBy = dependents;
        before = dependents;
        script = ''
          ${podman} network exists ${serviceName} || ${podman} network create \
            ${
            if netCfg.ipv4.subnet != null
            then "--subnet ${netCfg.ipv4.subnet} \\"
            else ""
          }
            ${
            if netCfg.ipv6.enable != null
            then "--ipv6 \\"
            else ""
          }
            ${
            if netCfg.ipv6.subnet != null
            then "--subnet ${netCfg.ipv6.subnet} \\"
            else ""
          }
            ${serviceName}
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${podman} network rm ${serviceName}";
        };
      };
    };
  in {
    virtualisation.oci-containers.containers = lib.concatMapAttrs serviceToContainers config.virtualisation.composter.services;
    systemd.services = lib.mapAttrs' serviceToNetwork config.virtualisation.composter.services;
  };
}
