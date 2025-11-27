{...}: {
  virtualisation.composter.apps.maven_vanutp_dev.services = {
    main = {
      image = "ghcr.io/dzikoysk/reposilite";
      traefik = {
        host = "maven.vanutp.dev";
        proxied = false;
      };
      volumes = [
        "./data:/app/data"
      ];
    };
  };
  vanutp.traefik.extraDynamicConfig = {
    http.routers.mvn_vtp_sh = {
      rule = "Host(`mvn.vtp.sh`)";
      middlewares = ["mvn_vtp_sh"];
      service = "noop@internal";
    };
    http.middlewares.mvn_vtp_sh.redirectregex = {
      regex = "^https://mvn\\.vtp\\.sh/(.*)";
      replacement = "https://maven.vanutp.dev/\${1}";
    };
  };
  vanutp.maskman.entries = [
    {
      name = "mvn.vtp.sh";
      proxied = false;
    }
  ];
}
