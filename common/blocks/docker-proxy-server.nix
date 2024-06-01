{
  pkgs,
  common,
  ...
}: let
  dataDir = "${common.constants.servicesDataRoot}/docker-proxy-server";
  configFile = (pkgs.formats.yaml {}).generate "distribution.yml" {
    version = "0.1";
    http = {
      addr = ":5000";
      headers.X-Content-Type-Options = ["nosniff"];
    };
    proxy = {
      remoteurl = "https://registry-1.docker.io";
      ttl = "12h";
    };
    storage = {
      cache.blobdescriptor = "inmemory";
      filesystem.rootdirectory = "/var/lib/registry";
    };
  };
in {
  virtualisation.composter.services.docker-proxy-server.main = {
    image = "docker.io/distribution/distribution:latest";
    volumes = [
      "${configFile}:/etc/docker/registry/config.yml:ro"
      "${dataDir}:/var/lib/registry"
    ];
    traefik.host = "dockerio.vanutp.dev";
  };
  system.activationScripts.traefik-create-data-dir.text = "mkdir -p ${dataDir}";
}
