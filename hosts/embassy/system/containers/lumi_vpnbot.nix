{config, ...}: {
  sops.secrets."services/lumi_vpnbot" = {};
  virtualisation.composter.apps.lumi_vpnbot = {
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/vanutp/vpnbot:latest";
      env_file = config.sops.secrets."services/lumi_vpnbot".path;
      volumes = [
        "./data:/data"
      ];
    };
  };
}
