{...}: {
  services.elasticsearch = {
    enable = true;
    listenAddress = "100.64.0.6";
    extraJavaOptions = [
      "-Xms512m"
      "-Xmx512m"
    ];
  };
  networking.firewall.allowedTCPPorts = [9200];
}
