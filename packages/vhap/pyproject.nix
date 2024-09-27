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
  package = python.pkgs.buildPythonPackage (
    project.renderers.buildPythonPackage {inherit python;}
  );

  shell = pkgs.mkShell {
    packages = [
      (python.withPackages (
        project.renderers.withPackages {inherit python;}
      ))
    ];
  };
}
