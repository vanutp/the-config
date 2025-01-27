pkgs: name: f: let
  inherit (pkgs) lib;
  valueToString = value:
    assert lib.elem (lib.typeOf value) [
      "int"
      "bool"
      "string"
      "null"
      "float"
      "path"
    ]
    || lib.isDerivation value;
      builtins.toJSON value;
  keyToString = nodeKey:
    if !lib.isDerivation nodeKey && lib.isAttrs nodeKey
    then
      lib.concatStringsSep " "
      (
        lib.mapAttrsToList
        (key: value: "${valueToString key}=${valueToString value}")
        nodeKey
      )
    else valueToString nodeKey;
  section = name: keys: children: let
    normalizedKeys =
      if !lib.isList keys
      then [keys]
      else keys;
    keysString = lib.concatMapStringsSep " " keyToString normalizedKeys;
    normalizedChildren =
      if
        lib.isString children
        || lib.isDerivation children
        || lib.isPath children
      then [children]
      else if lib.isAttrs children
      then lib.mapAttrsToList (name: value: node name value) children
      else children;
    childrenString =
      if normalizedChildren == null
      then ""
      else "{\n${lib.concatLines normalizedChildren}\n}";
  in ''
    ${valueToString name} ${keysString} ${childrenString}
  '';
  node = name: keys: section name keys null;
  block = name: section name [];
  text = lib.concatLines (f {inherit block node section;});
  origFile = pkgs.writeText "orig-file.kdl" text;
in
  pkgs.runCommand name {} ''
    ${lib.getExe pkgs.kdlfmt} format - < ${origFile} > $out
  ''
