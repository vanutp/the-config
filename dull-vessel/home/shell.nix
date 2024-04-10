{...}: {
  programs.zsh = {
    initExtraHost = ''
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=('newline')
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=('newline')
    '';
  };
}
