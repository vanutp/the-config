{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./containers
    ./disko.nix
    ./hardware-configuration.nix
    ./network.nix
    ./traefik.nix
    ./ukurboot.nix
    ./users.nix
    ./volumes.nix
  ];

  boot.loader.grub.enable = true;

  time.timeZone = "Europe/Berlin";

  setup.computerType = "server";

  systemd.network.wait-online.enable = false;

  networking.hostId = "1dc14032";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "restic-archives" ''
      set -euo pipefail
      if [[ $(id -u) -ne 0 ]]; then
        echo "This script must be ran as root" >&2
        exit 1
      fi
      export $(cat ${config.sops.secrets."restic/archives/repo-creds".path} | xargs)
      export RESTIC_PASSWORD_FILE=${config.sops.secrets."restic/archives/password".path}
      export RESTIC_REPOSITORY=s3:https://s3.eu-central-003.backblazeb2.com/vanutp-archives
      exec restic $@
    '')
  ];
}
