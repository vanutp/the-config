{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rdiff-backup
  ];
  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [443 24454];
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * * fox rdiff-backup ~/server/world/ ~/backup/ && rdiff-backup --force remove increments --older-than 7D --size ~/backup/"
    ];
  };
  vanutp.traefik.proxies = [
    {
      host = "map.vanutp.dev";
      target = "http://127.0.0.1:8100";
    }
  ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "hello@vanutp.dev";
  };
}
