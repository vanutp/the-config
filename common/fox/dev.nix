{...}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Ivan Filipenkov";
    userEmail = "hello@vanutp.dev";
  };
}
