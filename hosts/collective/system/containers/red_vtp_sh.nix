{...}: {
  virtualisation.composter.apps.red_vtp_sh.services = {
    main = {
      image = "quay.io/redlib/redlib:latest";
      traefik.host = "red.vtp.sh";
      user = "nobody";
      read_only = true;
      security_opt = ["no-new-privileges:true"];
      cap_drop = ["ALL"];
      environment = {
        ROBOTS_DISABLE_INDEXING = "on";
        REDLIB_DEFAULT_SHOW_NSFW = "on";
        REDLIB_DEFAULT_BLUR_NSFW = "on";
        REDLIB_DEFAULT_USE_HLS = "on";
        REDLIB_DEFAULT_BLUR_SPOILER = "on";
      };
    };
  };
}
