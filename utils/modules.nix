{
  lib,
  mode,
  ...
}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) attrNames flatten map pipe filter;
  modulesDir = ../modules;
  homeOrSystem = builtins.elemAt (lib.splitString "-" mode) 0;
in {
  imports = pipe modulesDir [
    readDir
    attrNames
    (map (dir: map (mode: "${modulesDir}/${dir}/${mode}.nix") ["generic" homeOrSystem]))
    flatten
    (filter pathExists)
  ];
}
