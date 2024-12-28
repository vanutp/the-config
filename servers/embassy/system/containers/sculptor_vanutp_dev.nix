{pkgs, ...}: let
  mkToml = (pkgs.formats.toml {}).generate;
  config = mkToml "sculptor.toml" {
    listen = "0.0.0.0:6665";
    assetsUpdaterEnabled = true;
    motd = {
      displayServerInfo = true;
      sInfoUptime = "Uptime: ";
      sInfoAuthClients = "Authenticated clients: ";
      sInfoDrawIndent = true;
      customText = ''[{"text": "Meow >_<"}]'';
    };
    authProviders = [
      {
        name = "tgauth";
        url = "https://mc-auth.vanutp.dev/session/minecraft/hasJoined";
      }
    ];
    limitations = {
      maxAvatarSize = 1000;
      maxAvatars = 50;
    };
    advancedUsers."76e3bc1c-02af-460f-91cf-64956b45d569" = {
      username = "vanutp";
      special = [0 0 0 0 0 0];
      pride = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0];
    };
  };
in {
  virtualisation.composter.apps.sculptor_vanutp_dev.services.main = {
    image = "ghcr.io/shiroyashik/sculptor:latest";
    traefik.host = "sculptor.vanutp.dev";
    volumes = [
      "${config}:/app/Config.toml:ro"
      "./data:/app/data"
      "./logs:/app/logs"
    ];
    environment = {
      RUST_LOG = "info";
      TZ = "Europe/Moscow";
    };
  };
}
