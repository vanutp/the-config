{pkgs, ...}: yamlPath:
builtins.fromJSON (
  builtins.readFile (
    pkgs.stdenv.mkDerivation {
      name = "readYaml-${builtins.baseNameOf yamlPath}";
      phases = ["buildPhase"];
      buildPhase = "${pkgs.yq}/bin/yq . ${yamlPath} > $out";
    }
  )
)
