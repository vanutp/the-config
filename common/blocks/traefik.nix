{
  common,
  config,
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    vanutp.traefik = {
      proxies = mkOption {
        type = types.listOf (types.submodule {
          options = {
            host = mkOption {type = types.str;};
            target = mkOption {type = types.str;};
          };
        });
        default = [];
      };
      acmeChallenge = mkOption {
        type = types.enum ["dns" "tls"];
        default = "dns";
      };
      tlsDomains = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = let
    configDir = "/etc/traefik";
    configFilePath = "${configDir}/traefik.yml";
    rulesDir = "${configDir}/rules";
    dataDir = "${common.constants.servicesDataRoot}/traefik";

    mkYaml = (pkgs.formats.yaml {}).generate;
    cloudflareRanges = [
      "173.245.48.0/20"
      "103.21.244.0/22"
      "103.22.200.0/22"
      "103.31.4.0/22"
      "141.101.64.0/18"
      "108.162.192.0/18"
      "190.93.240.0/20"
      "188.114.96.0/20"
      "197.234.240.0/22"
      "198.41.128.0/17"
      "162.158.0.0/15"
      "104.16.0.0/13"
      "104.24.0.0/14"
      "172.64.0.0/13"
      "131.0.72.0/22"
      "2400:cb00::/32"
      "2606:4700::/32"
      "2803:f800::/32"
      "2405:b500::/32"
      "2405:8100::/32"
      "2a06:98c0::/29"
      "2c0f:f248::/32"
    ];
    configFile = mkYaml "traefik.yml" {
      accessLog = {
        filePath = "/data/logs/access.json";
        format = "json";
        fields = {
          defaultMode = "keep";
          names.RequestAddr = "keep";
          headers.names.User-Agent = "keep";
        };
      };
      certificatesResolvers.default.acme =
        {
          storage = "/data/acme.json";
        }
        // (
          # TODO: can mkIf be used here?
          if config.vanutp.traefik.acmeChallenge == "dns"
          then {
            dnsChallenge.provider = "cloudflare";
          }
          else {
            tlsChallenge = {};
          }
        );
      entryPoints = {
        http = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "https";
            scheme = "https";
            permanent = true;
          };
        };
        https = {
          address = ":443";
          transport.respondingTimeouts.readTimeout = 120;
          forwardedHeaders.trustedIPs = cloudflareRanges;
          http.tls =
            {
              certResolver = "default";
            }
            // (
              # TODO: can mkIf be used here?
              if config.vanutp.traefik.acmeChallenge == "dns"
              then {
                # TODO: copy certificates from main server to others
                # instead of giving every server cloudflare access
                domains =
                  map (domain: {
                    main = domain;
                    sans = ["*.${domain}"];
                  })
                  config.vanutp.traefik.tlsDomains;
              }
              else {}
            );
        };
      };
      providers = {
        docker.exposedByDefault = false;
        file.directory = "/config/rules";
      };
    };
    rulesFile = mkYaml "rules.yml" {
      http =
        builtins.foldl'
        (a: b: lib.recursiveUpdate a b)
        {}
        (map (entry: let
            entryId = builtins.replaceStrings ["."] ["__"] entry.host;
          in {
            routers.${entryId} = {
              service = entryId;
              rule = "Host(`${entry.host}`)";
            };
            services.${entryId}.loadBalancer.servers = [
              {
                url = entry.target;
              }
            ];
          })
          config.vanutp.traefik.proxies);
    };
  in {
    systemd.tmpfiles.rules = [
      "L+ ${configFilePath} - - - - ${configFile}"
      "L+ ${rulesDir}/rules.yml - - - - ${rulesFile}"
    ];
    # TODO: add an option to composter to disable network creation and use it
    virtualisation.oci-containers.containers.traefik = {
      image = "docker.io/traefik:latest";
      cmd = [
        "--configFile=/config/traefik.yml"
      ];
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        # TODO: restart if config files change
        "${configDir}:/config:ro"
        "${dataDir}:/data"
        "/nix/store:/nix/store:ro"
      ];
      environmentFiles =
        if config.vanutp.traefik.acmeChallenge == "dns"
        then [config.sops.secrets."services/traefik-cloudflare-config".path]
        else [];
      extraOptions = [
        "--network=host"
      ];
    };
    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [443];
    system.activationScripts.traefik-create-data-dir.text = "mkdir -p ${dataDir}";
  };
}
