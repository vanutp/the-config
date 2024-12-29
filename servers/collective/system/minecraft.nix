{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    temurin-bin-17
    rdiff-backup
  ];
  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [443 24454];
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * * fox rdiff-backup ~/server/world/ ~/backup/ 
                     && rdiff-backup --force remove increments --older-than 7D --size ~/backup/"
    ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."map.vanutp.dev" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8100";
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "hello@vanutp.dev";
  };
}
