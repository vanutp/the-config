{inputs, ...}: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  programs.zsh = {
    initExtraHost = ''
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=('newline')
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=('newline')
      if [[ -z "$VANUTP_WORKDIR_CHANGED" && "$PWD" == "$HOME" && -d ~/playground ]]; then
        cd ~/playground
        VANUTP_WORKDIR_CHANGED=true
      fi
    '';
  };
}
