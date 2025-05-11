{lib, ...}: let
  inherit (builtins) readDir filter;
  inherit (lib) attrNames map pipe;
  modulesDir = ./.;
in {
  imports = pipe modulesDir [
    readDir
    attrNames
    (filter (app: app != "default.nix"))
    (filter (lib.hasSuffix ".nix"))
    (map (app: "${modulesDir}/${app}"))
  ];
}
