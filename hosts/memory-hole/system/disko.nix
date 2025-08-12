{lib, ...}: {
  disko.devices = {
    disk = lib.listToAttrs (map (disk: {
      name = disk;
      value = {
        type = "disk";
        device = "/dev/${disk}";
        content = {
          type = "gpt";
          partitions = {
            biosboot = {
              priority = 1;
              type = "EF02"; # biosboot
              size = "1M";
            };
            boot = {
              priority = 2;
              size = "4G";
              content = {
                type = "mdraid";
                name = "bootraid";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    }) ["sda" "sdb" "sdc" "sdd"]);
    mdadm.bootraid = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/boot";
      };
    };
    zpool.rpool = {
      type = "zpool";
      mode = "raidz";
      rootFsOptions = {
        mountpoint = "none";
        acltype = "posixacl";
        xattr = "sa";
        canmount = "off";
        dnodesize = "auto";
        relatime = "on";
      };
      options.ashift = "12";
      datasets = {
        "root" = {
          type = "zfs_fs";
          options = {
            canmount = "noauto";
            mountpoint = "legacy";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "file:///tmp/secret.key";
          };
          mountpoint = "/";
        };
      };
    };
  };
}
