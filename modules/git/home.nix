{
  config,
  lib,
  ...
}: {
  programs.git = lib.mkIf (config.home.username == "fox") {
    enable = true;
    lfs.enable = true;
    userName = "Ivan Filipenkov";
    userEmail = "hello@vanutp.dev";
  };
}
