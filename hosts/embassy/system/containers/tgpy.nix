{...}: let
  mkTgpy = {
    volumes ? [],
    image ? "tgpy/tgpy:latest",
  }: {
    services.tgpy = {
      inherit image;
      deploy.resources.limits = {
        cpus = "1";
        pids = 64;
      };
      volumes = ["./data:/data"] ++ volumes;
    };
  };
in {
  virtualisation.composter.apps = {
    tgpy = mkTgpy {
      image = "tgpy/tgpy:dev";
    };
    tgpy_0 = mkTgpy {};
    tgpy_elena = mkTgpy {};
    tgpy_kitlix = mkTgpy {};
    tgpy_pufl = mkTgpy {};
    tgpy_samat = mkTgpy {};
    tgpy_samat2 = mkTgpy {
      volumes = ["../tgpy_samat/data/modules:/data/modules"];
    };
    tgpy_tmat = mkTgpy {};
  };
}
