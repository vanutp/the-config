{...}: {
  vanutp.traefik.extraDynamicConfig = {
    http.routers.tgpy_tmat_me = {
      rule = "Host(`tgpy.tmat.me`)";
      middlewares = ["tgpy_tmat_me"];
      service = "noop@internal";
    };
    http.middlewares.tgpy_tmat_me.redirectregex = {
      regex = "^https://tgpy\\.tmat\\.me/(.*)";
      replacement = "https://papercraft.tmat.me/tgpy/\${1}";
    };
    http.routers.tgpy_dev = {
      rule = "Host(`tgpy.dev`)";
      middlewares = ["tgpy_dev"];
      service = "noop@internal";
    };
    http.middlewares.tgpy_dev.redirectregex = {
      regex = "^https://tgpy\\.dev/(.*)";
      replacement = "https://papercraft.tmat.me/tgpy/\${1}";
    };
  };
}
