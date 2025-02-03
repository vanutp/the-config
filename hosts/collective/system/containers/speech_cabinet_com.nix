{
  config,
  lib,
  ...
}: let
  cfg = {
    host,
    tag,
  }: {
    auth = ["ghcr"];
    services = let
      image = "ghcr.io/tm-a-t/speech-cabinet:${tag}";
      NEXTAUTH_URL = "https://${host}";
      limits = {
        cpus = "2.5";
        pids = 1024;
        memory = "1G";
      };
      env_file = config.sops.secrets."services/${builtins.replaceStrings ["." "-"] ["_" "_"] host}".path;
    in {
      web = {
        inherit image;
        command = ["web"];
        deploy.resources.limits = limits;
        traefik.host = host;
        inherit env_file;
        environment = {
          inherit NEXTAUTH_URL;
        };
        volumes = [
          "temp:/app/temp"
          "./music:/app/public/music"
        ];
        restart = "always";
      };
      worker = {
        inherit image;
        command = ["worker"];
        deploy.resources.limits = limits;
        inherit env_file;
        environment = {
          inherit NEXTAUTH_URL;
          WEB_URL = "http://web:3000";
        };
        volumes = [
          "temp:/app/temp"
        ];
      };
    };
    volumes.temp = {};
  };
in {
  virtualisation.composter.apps = {
    speech_cabinet_com = cfg {
      host = "speech-cabinet.com";
      tag = "latest";
    };
    dev_speech_cabinet_com = cfg {
      host = "dev.speech-cabinet.com";
      tag = "dev";
    };
  };

  sops.secrets."services/speech_cabinet_com" = {};
  sops.secrets."services/dev_speech_cabinet_com" = {};
  sops.secrets."vhap-compose-update/speech_cabinet_com" = {};
  sops.secrets."vhap-compose-update/dev_speech_cabinet_com" = {};
  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/speech_cabinet_com";
      service = "speech_cabinet_com";
    }
    {
      key = config.sops.placeholder."vhap-compose-update/dev_speech_cabinet_com";
      service = "dev_speech_cabinet_com";
    }
  ];
}
