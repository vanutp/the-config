{...}: {
  virtualisation.composter.apps.tgbridge_vanutp_dev.services.main = {
    image = "ghcr.io/vanutp/tgbridge:latest";
    traefik.host = "tgbridge.vanutp.dev";
  };
}
