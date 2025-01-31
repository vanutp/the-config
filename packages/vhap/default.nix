{
  pkgs,
  pyproject-nix,
  ...
}: let
  python = pkgs.python3;
  project = pyproject-nix.lib.project.loadPyproject {
    projectRoot = ./.;
  };
in {
  packages.vhap = python.pkgs.buildPythonPackage (
    project.renderers.buildPythonPackage {inherit python;}
  );
  devShells.vhap = pkgs.mkShell {
    packages = [
      (python.withPackages (
        project.renderers.withPackages {inherit python;}
      ))
    ];
  };
}
