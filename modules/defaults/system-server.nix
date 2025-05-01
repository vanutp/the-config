{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.setup.isServer {
  networking.useNetworkd = true;
  networking.useDHCP = false;
  # for `nixos-rebuild build-vm`
  virtualisation.vmVariant.networking.useDHCP = lib.mkForce true;

  security.sudo.wheelNeedsPassword = false;
  # to allow remote rebuild while connecting as non-root
  nix.settings.trusted-users = ["@wheel"];

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';

  security.acme = {
    acceptTerms = true;
    defaults.email = "hello@vanutp.dev";
  };
}
