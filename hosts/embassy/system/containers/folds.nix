{
  config,
  lib,
  ...
}: let
  services = ["avatar_emoji_bot" "flexdo" "smeshariki"];
in {
  virtualisation.composter.apps = lib.genAttrs services (name: {
    auth = ["ghcr"];
    services.main = {
      image = "ghcr.io/tm-a-t/folds:${name}";
      env_file = [
        config.sops.secrets."services/folds/api_id".path
        config.sops.secrets."services/folds/api_hash".path
        config.sops.secrets."services/folds/${name}".path
      ];
      volumes = [
        "./data:/app/.folds"
      ];
    };
  });
  sops.secrets = lib.genAttrs (
    [
      "services/folds/update"
      "services/folds/api_id"
      "services/folds/api_hash"
    ]
    ++ (map (name: "services/folds/${name}") services)
  ) (name: {});
  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."services/folds/update";
      inherit services;
    }
  ];
}
