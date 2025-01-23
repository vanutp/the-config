{...}: {
  virtualisation.composter.apps.telemap_vanutp_dev = {
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/vanutp/telemap:latest";
      traefik.host = "telemap.vanutp.dev";
    };
  };
}
