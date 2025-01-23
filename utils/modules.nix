{
  lib,
  mode,
  ...
}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) attrNames flatten map pipe filter;
  modulesDir = ../modules;
in {
  imports = pipe modulesDir [
    readDir
    attrNames
    (map (dir: map (mode: "${modulesDir}/${dir}/${mode}.nix") ["generic" mode]))
    flatten
    (filter pathExists)
  ];
}
