{pkgs, ...}: {
  services.redis.servers.main = {
    enable = true;
    port = 6379;
  };
  services.postgresql = {
    enable = true;
  };

  services.minio.enable = true;

  virtualisation.virtualbox = {
    host.enable = true;
    # host.enableExtensionPack = true;
  };
  users.groups.vboxusers.members = ["fox"];

  virtualisation.vmware.host.enable = true;

  environment.etc."mime.types".source = "${pkgs.mime-types}/etc/mime.types";

  boot.binfmt = {
    emulatedSystems = ["aarch64-linux"];
    registrations.aarch64-linux.fixBinary = true;
    registrations.aarch64-linux.openBinary = true;
  };

  networking.firewall.interfaces.int.allowedTCPPorts = [7000 7001];

  programs.adb.enable = true;
  users.groups.adbusers.members = ["fox"];

  documentation.dev.enable = true;
  environment.systemPackages = with pkgs; [linux-manual man-pages man-pages-posix];
}
