{...}: {
  imports = [
    ./composter-tests
    ./veyon
    ./apps.nix
    ./audio.nix
    ./dev.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./login.nix
    ./logiops.nix
    ./portals.nix
    ./security.nix
    ./strongswan.nix
    ./wireguard.nix
  ];

  setup.computerType = "laptop";

  time.timeZone = "Europe/Berlin";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.extraEntries = {
    "arch.conf" = ''
      title   Arch Linux
      linux   /vmlinuz-linux
      initrd  /initramfs-linux.img
      options rd.luks.name=b2a45394-b193-4705-9a35-a7dac6ed1a59=root root=/dev/mapper/root rootflags=subvol=@arch,compress=zstd:1,discard=async rw
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;

  security.pam.services.swaylock = {
    fprintAuth = true;
    allowNullPassword = true;
  };

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.NetworkManager.wantedBy = ["multi-user.target"];
  users.groups.networkmanager.members = ["fox"];
  networking.nameservers = ["1.1.1.1"];
  services.resolved.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;

  programs.dconf.enable = true;
  services.gpm.enable = true;
  programs.gamemode.enable = true;
  users.groups.gamemode.members = ["fox"];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  programs.nix-ld.enable = true;
}
