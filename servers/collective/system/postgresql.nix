{...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      # TYPE  DATABASE  USER  ADDRESS     METHOD
      host    all       all   0.0.0.0/0  scram-sha-256
    '';
    settings = {
      maintenance_work_mem = "3276MB";
      work_mem = "256MB";
      shared_buffers = "16GB";
      huge_pages = "on";
    };
  };
  networking.firewall.allowedTCPPorts = [5432];
  boot.kernel.sysctl."vm.nr_hugepages" = 8400;
}
