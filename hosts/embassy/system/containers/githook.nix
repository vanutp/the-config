{...}: {
  virtualisation.composter.apps.githook = {
    backup.enable = true;
    services.main = {
      image = "registry.vanutp.dev/vanutp/githook:latest";
      traefik = {
        host = "ci.vanutp.dev";
        paths = ["/trigger"];
      };
      env_file = "secrets.env";
      volumes = ["./data:/data"];
    };
  };
}
