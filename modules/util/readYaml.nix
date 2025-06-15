pkgs: yamlPath:
builtins.fromJSON (
  builtins.readFile (
    pkgs.stdenv.mkDerivation {
      name = "fromYAML";
      phases = ["buildPhase"];
      buildPhase = "${pkgs.yq}/bin/yq . ${yamlPath} > $out";
    }
  )
)
