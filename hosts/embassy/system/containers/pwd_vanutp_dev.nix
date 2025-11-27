{...}: {
  virtualisation.composter.apps.pwd_vanutp_dev = {
    backup.enable = true;
    services.vaultwarden = {
      image = "vaultwarden/server:latest";
      traefik = {
        host = "pwd.vanutp.dev";
        proxied = false;
      };
      environment = {
        DATABASE_MAX_CONNS = "2";
      };
      env_file = "secrets.env";
      volumes = ["./data:/data"];
    };
  };
}
