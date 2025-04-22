{config, ...}: let
  common = {
    image = "ghcr.io/constructor-space/memesearch:latest";
    volumes = [
      "./data:/data"
    ];
    environment = {
      EXTERNAL_URL = "https://memesearch.vanutp.dev";
    };
    env_file = config.sops.secrets."services/memesearch_vanutp_dev".path;
  };
in {
  virtualisation.composter.apps.memesearch_vanutp_dev.services = {
    bot =
      common
      // {
        command = ["/app/bot-cmd.sh"];
      };
    web =
      common
      // {
        command = ["python" "-m" "app.web"];
        traefik.host = "memesearch.vanutp.dev";
      };
  };
  sops.secrets."services/memesearch_vanutp_dev" = {};
  sops.secrets."vhap-compose-update/memesearch_vanutp_dev" = {};
  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/memesearch_vanutp_dev";
      services = ["memesearch_vanutp_dev"];
    }
  ];
}
