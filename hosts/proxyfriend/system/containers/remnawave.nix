{config, ...}: {
  virtualisation.composter.apps.remnawave.services.remnanode = {
    hostname = "remnanode";
    image = "remnawave/node:latest";
    network_mode = "host";
    restart = "always";
    ulimits.nofile = {
      soft = 1048576;
      hard = 1048576;
    };
    environment = {
      NODE_PORT = 2222;
    };
    env_file = config.sops.secrets.remnawave.path;
  };
  vanutp.traefik.proxies = [
    {
      rule = "Host(`cdn.rkp.vanutp.dev`) && PathPrefix(`/Lf3CwXfW8oQbf3Q`)";
      target = "http://127.0.0.1:2223";
      certresolver = "http";
    }
  ];
  vanutp.maskman.entries = [
    {
      name = "cdn.rkp.vanutp.dev";
      proxied = false;
    }
  ];
  networking.firewall.allowedTCPPorts = [2222];
}
