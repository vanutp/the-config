{...}: {
  virtualisation.composter.apps.tgpy_samat2.services.tgpy = {
    image = "tgpy/tgpy:latest";
    deploy.resources.limits = {
      cpus = "1";
      pids = 64;
    };
    volumes = [
      "./data:/data"
      "../tgpy_samat/data/modules:/data/modules"
    ];
  };
}
