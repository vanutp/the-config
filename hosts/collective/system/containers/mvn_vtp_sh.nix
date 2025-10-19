{...}: {
  virtualisation.composter.apps.mvn_vtp_sh.services = {
    main = {
      image = "ghcr.io/dzikoysk/reposilite";
      traefik.host = "mvn.vtp.sh";
      volumes = [
        "./data:/app/data"
      ];
    };
  };
}
