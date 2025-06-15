{
  config,
  pkgs-unstable,
  ...
}: {
  services.anki-sync-server = {
    enable = true;
    package = pkgs-unstable.anki-sync-server;
    address = "127.0.0.1";
    port = 27701;
    users = [
      {
        username = "vanutp";
        passwordFile = config.sops.secrets."services/anki".path;
      }
    ];
  };
  vanutp.traefik.proxies = [
    {
      host = "anki.vanutp.dev";
      target = "http://127.0.0.1:27701";
    }
  ];
}
