{...}: {
  virtualisation.composter.apps.n8n_vanutp_dev = {
    services = {
      n8n = {
        image = "docker.n8n.io/n8nio/n8n";
        environment = {
          GENERIC_TIMEZONE = "Europe/Berlin";
          N8N_DIAGNOSTICS_ENABLED = "false";
          TZ = "Europe/Berlin";
        };
        env_file = "secrets.env";
        traefik.host = "n8n.vanutp.dev";
        volumes = ["./data:/home/node/.n8n"];
      };
    };
  };
}
