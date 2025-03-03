{config, ...}: {
  sops.secrets."vhap-compose-update/AvatarEmojiBot" = {};
  sops.secrets."vhap-compose-update/csai_tmat_me" = {};
  sops.secrets."vhap-compose-update/vanutp_music_bot" = {};
  sops.secrets."vhap-compose-update/mc_auth_vanutp_dev" = {};
  sops.secrets."vhap-compose-update/samat_tiktok" = {};
  sops.secrets."vhap-compose-update/cuspace_vanutp_dev" = {};
  sops.secrets."vhap-compose-update/telemap_vanutp_dev" = {};

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
      "cuspace_vanutp_dev"
      "telemap_vanutp_dev"
    ];
}
