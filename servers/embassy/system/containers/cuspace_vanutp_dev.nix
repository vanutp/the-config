{...}: {
  virtualisation.composter.apps.cuspace_vanutp_dev = {
    auth = ["ghcr"];
    services.main = {
      image = "ghcr.io/constructor-space/backend-python:latest";
      env_file = "secrets.env";
      volumes = ["./data:/data"];
      traefik.host = "cuspace.vanutp.dev";
    };
  };
}
