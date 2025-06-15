{
  config,
  lib,
  hostname,
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
          backups = mkOption {
            type = types.attrsOf (types.submodule ({name, ...}: {
              options = {
                tag = mkOption {
                  type = types.str;
                  default = name;
                };
                paths = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
                dynamicFilesFrom = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                extraBackupArgs = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
                backupPrepareCommand = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                backupCleanupCommand = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                schedule = mkOption {
                  type = types.str;
                  default = "Sun *-*-* 03:00:00";
                };
                randomizedDelay = mkOption {
                  type = types.str;
                  default = "1h";
                };
              };
            }));
          };
        };
      };
      default = {};
    };
  };
  config = {
    vanutp.backup.backups = lib.pipe config.virtualisation.composter.apps [
      (lib.filterAttrs (name: app: app.backup.enable))
      (lib.mapAttrs' (name: app: {
        name = "composter-${name}";
        value = {
          tag = "composter:${name}";
          paths = lib.pipe app.services [
            builtins.attrValues
            (map (svc: svc.volumes or []))
            lib.flatten
            (map (vol: builtins.elemAt (lib.splitString ":" vol) 0))
            (builtins.filter (lib.hasPrefix "./"))
            (map (vol: app.appDir + (lib.removePrefix "." vol)))
            lib.unique
          ];
        };
      }))
      (lib.filterAttrs (name: cfg: cfg.paths != []))
    ];
    services.restic.backups = lib.mkIf config.vanutp.backup.enable (
      lib.mapAttrs (name: cfg: {
        initialize = true;
        repository = "s3:${config.vanutp.backup.s3-url}";
        environmentFile = config.sops.secrets."restic/repo-creds".path;
        passwordFile = config.sops.secrets."restic/password".path;
        extraBackupArgs =
          [
            "--tag=${cfg.tag}"
          ]
          ++ cfg.extraBackupArgs;
        pruneOpts = [
          "--keep-last=10"
          "--tag=${cfg.tag}"
          "--host=${hostname}"
        ]; # TODO: forget/prune separately
        timerConfig = {
          OnCalendar = cfg.schedule;
          Persistent = true;
          RandomizedDelaySec = cfg.randomizedDelay;
        };
        inherit (cfg) paths dynamicFilesFrom backupPrepareCommand backupCleanupCommand;
      })
      config.vanutp.backup.backups
    );
  };
}
