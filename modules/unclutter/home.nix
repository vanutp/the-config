# thx to xdg-ninja
{
  config,
  lib,
  ...
}: let
  variables = {
    WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
    PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
    NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    NODE_REPL_HISTORY = "${config.xdg.dataHome}/node_repl_history";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
    REDISCLI_HISTFILE = "${config.xdg.dataHome}/redis/rediscli_history";
  };
in {
  home.sessionVariables = variables;
  systemd.user.sessionVariables = variables;
  programs.zsh.shellAliases = {
    wget = "wget --hsts-file=\"${config.xdg.dataHome}/wget-hsts\"";
    adb = "HOME=\"${config.xdg.dataHome}\"/android adb";
    mc = "mc --config-dir \"${config.xdg.configHome}/mc\"";
  };
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  home.activation.create-wakatime-home = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.xdg.configHome}/wakatime"
    run mkdir -p "${config.xdg.configHome}/ipython"
  '';
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  xdg.configFile."python/pythonrc".text = ''
    #!/usr/bin/env python3
    # This entire thing is unnecessary post v3.13.0a3
    # https://github.com/python/cpython/issues/73965

    def is_vanilla() -> bool:
        """ :return: whether running "vanilla" Python """
        import sys
        return not hasattr(__builtins__, '__IPYTHON__') and 'bpython' not in sys.argv[0]


    def setup_history():
        """ read and write history from state file """
        import os
        import atexit
        import readline
        from pathlib import Path

        # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
        if state_home := os.environ.get('XDG_STATE_HOME'):
                state_home = Path(state_home)
        else:
            state_home = Path.home() / '.local' / 'state'
        if not state_home.is_dir():
            print("Error: XDG_SATE_HOME does not exist at", state_home)

        history: Path = state_home / 'python_history'

        # https://github.com/python/cpython/issues/105694
        if not history.is_file():
            with open(history,"w") as f:
                f.write("_HiStOrY_V2_" + "\
    \
    ") # breaks on macos + python3 without this.

        readline.read_history_file(history)
        atexit.register(readline.write_history_file, history)


    if is_vanilla():
        setup_history()
  '';
  xdg.configFile."npm/npmrc".text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    tmp=''${XDG_RUNTIME_DIR}/npm
  '';
}
