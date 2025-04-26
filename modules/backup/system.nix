{
  config,
  lib,
  ...
}: {
  options = with lib; {
    vanutp.backup = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          s3-url = mkOption {
            type = types.str;
          };
        };
      };
      default = {};
    };
  };
  config = lib.mkIf config.vanutp.backup.enable {
    services.restic.backups = lib.pipe config.virtualisation.composter.apps [
      (lib.filterAttrs (name: app: app.backup.enable))
      (lib.mapAttrs' (name: app: {
        inherit name;
        value = lib.pipe app.services [
          builtins.attrValues
          (map (svc: svc.volumes or []))
          lib.flatten
          (map (vol: builtins.elemAt (lib.splitString ":" vol) 0))
          (builtins.filter (lib.hasPrefix "./"))
          (map (vol: app.appDir + (lib.removePrefix "." vol)))
          lib.unique
        ];
      }))
      (lib.filterAttrs (name: paths: paths != []))
      (lib.mapAttrs'
        (name: paths: {
          name = "composter-${name}";
          value = let
            tag = "composter:${name}";
          in {
            initialize = true;
            repository = "s3:${config.vanutp.backup.s3-url}";
            environmentFile = config.sops.secrets."restic/repo-creds".path;
            passwordFile = config.sops.secrets."restic/password".path;
            extraBackupArgs = [
              "--tag=${tag}"
            ];
            inherit paths;
            pruneOpts = [
              "--keep-last=10"
              "--tag=${tag}"
            ];
            timerConfig = {
              OnCalendar = "Sun *-*-* 03:00:00";
              Persistent = true;
              RandomizedDelaySec = "10m";
            };
          };
        }))
    ];

    sops.secrets."restic/repo-creds" = {};
    sops.secrets."restic/password" = {};
  };
}
