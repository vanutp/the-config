{...}: {
  virtualisation.composter.apps.tgpy_0.services.tgpy = {
    image = "tgpy/tgpy:latest";
    deploy.resources.limits = {
      cpus = "1";
      pids = 64;
    };
    volumes = ["./data:/data"];
  };
}
