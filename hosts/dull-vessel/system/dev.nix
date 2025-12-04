{pkgs, ...}: {
  services.redis = {
    package = pkgs.valkey;
    servers.main = {
      enable = true;
      port = 6379;
    };
  };
  services.postgresql = {
    enable = true;
    extensions = ps:
      with ps; [
        pgvector
      ];
  };

  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
  };

  virtualisation.virtualbox = {
    host.enable = true;
    # host.enableExtensionPack = true;
  };
  users.groups.vboxusers.members = ["fox"];

  environment.etc."mime.types".source = "${pkgs.mailcap}/etc/mime.types";

  boot.binfmt = {
    emulatedSystems = ["aarch64-linux"];
    registrations.aarch64-linux.fixBinary = true;
    registrations.aarch64-linux.openBinary = true;
  };

  networking.firewall.interfaces.int.allowedTCPPorts = [7000 7001];

  programs.adb.enable = true;
  users.groups.adbusers.members = ["fox"];

  documentation.dev.enable = true;
  environment.systemPackages = with pkgs; [man-pages man-pages-posix];
}
