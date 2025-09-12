{
  config,
  lib,
  ...
}: {
  options = let
    inherit (lib) mkOption;
    inherit (lib.types) str attrsOf int submodule;
  in {
    vanutp.volumes = mkOption {
      type = attrsOf (submodule ({name, ...}: {
        options = {
          path = mkOption {
            type = str;
            default = "/srv/${name}";
          };
          uid = mkOption {
            type = int;
          };
          gid = mkOption {
            type = int;
          };
        };
      }));
    };
  };
  config = {
    vanutp.volumes = {
      media-server = {
        path = "/srv/media";
        uid = 1000;
        gid = 2000;
      };
    };
    users.groups.media-server = {
      members = ["fox" "lumi"];
      gid = config.vanutp.volumes.media-server.gid;
    };
    systemd.tmpfiles.settings.volumes =
      lib.mapAttrs' (_: cfg: {
        name = "${cfg.path}";
        value = {
          d = {
            user = builtins.toString cfg.uid;
            group = builtins.toString cfg.gid;
            mode = "2770";
          };
          # TODO: set ACLs (for media-server only?)
          # default:user::rwx
          # default:group::rwx
          # default:other::r-x
        };
      })
      config.vanutp.volumes;
    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = lib.concatLines (
        lib.mapAttrsToList
        (_: cfg: "${cfg.path} 100.111.249.84(rw,nohide,insecure,no_subtree_check,no_root_squash)")
        config.vanutp.volumes
      );
    };
    networking.firewall = {
      allowedTCPPorts = [2049 4000 4001 4002];
      allowedUDPPorts = [2049 4000 4001 4002];
    };
  };
}
