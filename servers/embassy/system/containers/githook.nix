{...}: {
  virtualisation.composter.apps.githook.services.main = {
    image = "registry.vanutp.dev/vanutp/githook:latest";
    traefik = {};
    labels = {
      "traefik.http.routers.ci_vanutp_dev_trigger.rule" = "Host(`ci.vanutp.dev`) && PathPrefix(`/trigger`)";
    };
    env_file = "secrets.env";
    volumes = ["./data:/data"];
  };
}
