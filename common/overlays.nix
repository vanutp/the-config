[
  (self: super: {
    foxlib = let
      python3 = super.lib.getExe super.pkgs.python3;
    in {
      writePythonScript = name: text:
        super.pkgs.writeTextFile {
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
    };
  })
]
