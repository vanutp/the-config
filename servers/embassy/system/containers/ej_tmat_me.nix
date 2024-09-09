{...}: {
  virtualisation.composter.apps.ej_tmat_me.services.main = {
    image = "registry.vanutp.dev/tm_a_t/art_ejudge:latest";
    traefik.host = "ej.tmat.me";
  };
}
