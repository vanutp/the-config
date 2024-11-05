{
  pkgs,
  pkgs-unstable,
}:
pkgs.writeShellApplication {
  name = "foxshot";
  runtimeInputs = with pkgs; [grim jq slurp wl-clipboard pkgs-unstable.wayfreeze satty];
  text = builtins.readFile ./foxshot.sh;
}
