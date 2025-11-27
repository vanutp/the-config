{...}: {
  virtualisation.composter.apps.logbox_vanutp_dev.services.main = {
    image = "registry.vanutp.dev/vanutp/logbox:latest";
    traefik = {
      host = "logbox.vanutp.dev";
      proxied = false;
    };
  };
}
