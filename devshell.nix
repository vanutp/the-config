{pkgs, ...}: {
  devShells.default = pkgs.mkShell {
    # required for ignis dev
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];
    buildInputs = with pkgs; [
      glib
      gobject-introspection
      gtk4
      gtk4-layer-shell
      libpulseaudio
    ];

    packages = with pkgs; [
      (writeShellApplication {
        name = "nixos-apply";

        runtimeInputs = [
          nixos-rebuild
          home-manager
          nix-output-monitor
        ];

        text = ''
          set -e
          args=()
          prefix=()
          if [[ $# == 0 ]]; then
            prefix=(sudo)
          elif [[ "$1" == "home" ]]; then
            home-manager switch -L --show-trace --log-format internal-json -v |& nom --json
            exit 0
          else
            args=(--target-host "$1" --use-remote-sudo)
          fi
          "''${prefix[@]}" nixos-rebuild switch --flake . --show-trace --log-format internal-json -v "''${args[@]}" |& nom --json
        '';
      })
    ];
  };
}
