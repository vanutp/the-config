{...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      # TYPE  DATABASE  USER  ADDRESS     METHOD
      # podman + wg networks
      host    all       all   10.0.0.0/8  scram-sha-256
    '';
  };
  networking.firewall.allowedTCPPorts = [5432];
}
