pkgs:
pkgs.writeShellApplication {
  name = "foxshot";
  runtimeInputs = with pkgs; [grim jq slurp wl-clipboard pkgs.wayfreeze satty];
  text = builtins.readFile ./foxshot.sh;
}
