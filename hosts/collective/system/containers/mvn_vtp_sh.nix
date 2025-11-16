{...}: {
  virtualisation.composter.apps.mvn_vtp_sh.services = {
    main = {
      image = "ghcr.io/dzikoysk/reposilite";
      traefik = {
        host = "mvn.vtp.sh";
        proxied = false;
      };
      volumes = [
        "./data:/app/data"
      ];
    };
  };
}
