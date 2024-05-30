{pkgs, ...}: let
  python3 = pkgs.lib.getExe pkgs.python3;
in {
  writePythonScript = name: text:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${python3}
        ${text}
      '';
      checkPhase = ''
        ${python3} -m py_compile $out
      '';
    };
}
