{
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = (
      builtins.replaceStrings
      ["@font@"]
      [config.preferences.font.monospace]
      (builtins.readFile ./wezterm.lua)
    );
    package = pkgs.wezterm.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./5264.patch
        ];
    });
  };
}
