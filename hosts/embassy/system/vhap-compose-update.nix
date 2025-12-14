{config, ...}: {
  services.vhap-compose-update.entries =
    map (
      service: {
        key = config.sops.placeholder."vhap-compose-update/${service}";
        services = [service];
      }
    ) [
      "csai_tmat_me"
      "vanutp_music_bot"
      "mc_auth_vanutp_dev"
      "samat_tiktok"
      "telemap_vanutp_dev"
      "logbox_vanutp_dev"
      "lumi_vpnbot"
      "tgbridge_vanutp_dev"
    ];
}
