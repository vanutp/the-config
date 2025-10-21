{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  programs.nix-index = {
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  programs.zsh = {
    initContent = ''
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=('newline')
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=('newline')
      if [[ -z "$VANUTP_WORKDIR_CHANGED" && "$PWD" == "$HOME" && -d ~/playground ]]; then
        cd ~/playground
        VANUTP_WORKDIR_CHANGED=true
      fi
    '';
  };
}
