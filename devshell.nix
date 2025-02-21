{pkgs, ...}: {
  devShells.default = pkgs.mkShell {
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
            home-manager switch -L --show-trace
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
