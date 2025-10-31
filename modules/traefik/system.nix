{
  config,
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    vanutp.traefik = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      config = mkOption {
        type = types.anything;
      };
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
      # TODO: raise an error if requestWildcardCertsFor is set but acmeChallenge != dns
      requestWildcardCertsFor = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      extraDynamicConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
      };
      limits = mkOption {
        type = types.submodule {
          options = {
            cpus = mkOption {type = types.str;};
            memory = mkOption {type = types.str;};
          };
        };
        default = {
          cpus = "2";
          memory = "2G";
        };
      };
    };
  };

  config = let
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
    rulesFile = mkYaml "rules.yml" (
      if (config.vanutp.traefik.proxies != [])
      then {
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
      }
      else {}
    );
    extraDynamicConfigFile = mkYaml "extra.yml" config.vanutp.traefik.extraDynamicConfig;
    rulesDir = pkgs.stdenv.mkDerivation {
      name = "traefik-rules";
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out
        cp ${rulesFile} $out/rules.yml
        cp ${extraDynamicConfigFile} $out/extra.yml
      '';
    };
    configFile = mkYaml "traefik.yml" config.vanutp.traefik.config;
  in
    lib.mkIf config.vanutp.traefik.enable {
      vanutp.traefik.config = {
        accessLog = {
          filePath = "/data/logs/access.json";
          format = "json";
          fields = {
            defaultMode = "keep";
            names.RequestAddr = "keep";
            headers.names.User-Agent = "keep";
          };
        };
        certificatesResolvers =
          {
            default.acme =
              {
                storage = "/data/tls/acme.json";
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
          }
          // (
            if config.vanutp.traefik.acmeChallenge == "dns"
            then {
              http.acme = {
                tlsChallenge = {};
                storage = "/data/tls/acme-http.json";
              };
            }
            else {}
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
                    config.vanutp.traefik.requestWildcardCertsFor;
                }
                else {}
              );
          };
        };
        providers = {
          docker.exposedByDefault = false;
          file.directory = rulesDir;
        };
      };
      virtualisation.composter.apps.traefik.services.traefik = {
        image = "traefik:latest";
        command = "--configFile=${configFile}";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "./data:/data"
          "/nix/store:/nix/store:ro"
        ];
        network_mode = "host";
        env_file =
          if config.vanutp.traefik.acmeChallenge == "dns"
          # TODO: move out of services/
          then [config.sops.secrets."services/traefik-cloudflare-config".path]
          else [];
        deploy.resources.limits = config.vanutp.traefik.limits;
      };
      networking.firewall.allowedTCPPorts = [80 443];
      networking.firewall.allowedUDPPorts = [443];
      system.activationScripts.create-traefik-dirs.text = ''
        traefik_dir=/srv/vhap/traefik
        mkdir -p $traefik_dir/data/logs $traefik_dir/data/tls
      '';
    };
}
