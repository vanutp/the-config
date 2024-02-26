{config, ...}: {
  environment.etc = {
    "xdg/Veyon Solutions/Veyon.conf".source = ./Veyon.conf;
    "veyon/keys/private/vanutp/key" = {
      source = config.sops.secrets."veyon_privkey".path;
      mode = "0440";
      user = "fox";
      group = "users";
    };
    "veyon/keys/public/vanutp/key".source = ./public.key;
  };
}
