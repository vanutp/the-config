{...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      # TYPE  DATABASE  USER  ADDRESS       METHOD
      # podman networks (actually podman uses only 10.89.0.0-10.255.255.255, but i don't want to clutter the config)
      host    all       all   10.128.0.0/9  scram-sha-256
    '';
  };
}
