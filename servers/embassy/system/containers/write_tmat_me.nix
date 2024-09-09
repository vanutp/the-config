{...}: {
  virtualisation.composter.apps.write_tmat_me = {
    auth = ["foxlab"];
    services.write = {
      image = "registry.vanutp.dev/tm_a_t/write:latest";
      traefik.host = "write.tmat.me";
    };
  };
}
