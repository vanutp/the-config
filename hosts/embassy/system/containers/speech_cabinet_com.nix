{...}: {
  virtualisation.composter.apps.speech_cabinet_com = {
    auth = ["ghcr"];
    services = let
      image = "ghcr.io/tm-a-t/speech-cabinet:latest";
      NEXTAUTH_URL = "https://speech-cabinet.com";
      limits = {
        cpus = "2.5";
        pids = 256;
        memory = "1G";
      };
    in {
      web = {
        inherit image;
        command = ["web"];
        deploy.resources.limits = limits;
        traefik.host = "speech-cabinet.com";
        env_file = "secrets.env";
        environment = {
          inherit NEXTAUTH_URL;
        };
        volumes = [
          "temp:/app/temp"
        ];
        restart = "always";
      };
      worker = {
        inherit image;
        command = ["worker"];
        deploy.resources.limits = limits;
        env_file = "secrets.env";
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
}
