{...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      # TYPE  DATABASE  USER  ADDRESS     METHOD
      host    all       all   0.0.0.0/0  scram-sha-256
    '';
  };
  networking.firewall.allowedTCPPorts = [5432];
}
