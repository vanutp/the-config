{config, ...}: {
  services.vhap-compose-update = {
    enable = true;
    # TODO: fix permissions?
    user = "root";
    group = "root";
    port = 8010;
    baseDir = "/srv/vhap";
    logsDir = "/srv/vhap/_vhap_update_logs";
    # TODO: make it better. now i have to enter service names 3 times
    entries =
      map (
        service: {
          key = config.sops.placeholder."vhap-compose-update/${service}";
          inherit service;
        }
      ) [
        "AvatarEmojiBot"
        "csai_tmat_me"
        "vanutp_music_bot"
        "mc_auth_vanutp_dev"
        "samat_tiktok"
        "cuspace_vanutp_dev"
      ];
  };
}
