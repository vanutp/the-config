{
  config,
  lib,
  hostname,
  mode,
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
          remotes = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                path = mkOption {
                  type = types.str;
                };
                rcloneConfig = mkOption {
                  type = types.nullOr (types.attrsOf (types.oneOf [
                    types.str
                    types.bool
                  ]));
                  default = null;
                };
              };
            });
          };
          backups = mkOption {
            type = types.attrsOf (types.submodule ({name, ...}: {
              options = {
                remote = mkOption {
                  type = types.str;
                  default = "default";
                };
                tag = mkOption {
                  type = types.str;
                  default = name;
                };
                paths = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
                exclude = mkOption {
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
  config = let
    globalCfg = config.vanutp.backup;
  in
    lib.mkIf globalCfg.enable {
      assertions = [
        {
          assertion = (mode == "home") -> (builtins.all (x: x.rcloneConfig == null) (builtins.attrValues globalCfg.remotes));
          message = "vanutp.backup.remotes.<name>.rcloneConfig cannot be used in home mode";
        }
      ];
      services.restic.backups =
        lib.mapAttrs (name: cfg: {
          initialize = true;
          repository = globalCfg.remotes.${cfg.remote}.path;
          rcloneConfig = lib.mkIf (mode == "system") globalCfg.remotes.${cfg.remote}.rcloneConfig;
          environmentFile = config.sops.secrets."restic/${cfg.remote}/repo-creds".path;
          passwordFile = config.sops.secrets."restic/${cfg.remote}/password".path;
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
          inherit (cfg) paths exclude dynamicFilesFrom backupPrepareCommand backupCleanupCommand;
        })
        globalCfg.backups;
    };
}
