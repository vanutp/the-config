{common, ...}: {
  imports = [
    common.blocks.traefik
    ./containers
  ];
  vanutp.traefik.requestWildcardCertsFor = ["vtp.sh"];
  sops.secrets."services/traefik-cloudflare-config" = {};
}
