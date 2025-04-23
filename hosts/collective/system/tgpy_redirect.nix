{...}: {
  vanutp.traefik.extraDynamicConfig = {
    http.routers.tgpy_tmat_me = {
      rule = "Host(`tgpy.tmat.me`)";
      middlewares = ["tgpy_tmat_me"];
      service = "noop@internal";
    };
    http.middlewares.tgpy_tmat_me.redirectregex = {
      regex = "^https://tgpy\\.tmat\\.me/(.*)";
      replacement = "https://tgpy.dev/\${1}";
    };
  };
}
