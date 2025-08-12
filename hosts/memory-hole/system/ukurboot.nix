{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelParams = ["ip=65.21.206.44::65.21.206.1:255.255.255.192:myhost::none"];
    kernelModules = ["igb"];
    initrd = {
      kernelModules = ["igb"];

      systemd = rec {
        enable = true;
        packages = with pkgs; [iproute2];
        initrdBin = packages;
        users.root.shell = "/bin/sh";
        emergencyAccess = true;
      };

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 999;
          authorizedKeys = [config.setup.pubkeys.main];
          # Copied during activation
          hostKeys = ["/etc/secrets/boot_ssh_ed25519_key"];
        };
      };
    };
  };
}
