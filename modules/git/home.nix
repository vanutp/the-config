{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  home.packages = [pkgs-unstable.mergiraf];
  programs.git = lib.mkIf (config.home.username == "fox") {
    enable = true;
    lfs.enable = true;
    userName = "Ivan Filipenkov";
    userEmail = "hello@vanutp.dev";
    delta.enable = true;
    extraConfig = {
      core.attributesfile = builtins.toString (pkgs.runCommand "gitattributes" {} ''
        ${lib.getExe pkgs-unstable.mergiraf} languages --gitattributes > $out
      '');
      "merge \"mergiraf\"" = {
        name = "mergiraf";
        driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
      };
    };
  };
}
