{pkgs, ...}: {
  programs.anyrun = {
    enable = true;
    # package = pkgs-unstable.anyrun;
    config = {
      closeOnClick = true;
      showResultsImmediately = true;
      plugins = map (x: "${pkgs.anyrun}/lib/${x}") [
        "libapplications.so"
        "libsymbols.so"
        "librink.so"
        "libtranslate.so"
        "libdictionary.so"
        "libwebsearch.so"
        # "libnix_run.so"
      ];
    };
    extraConfigFiles = {
      "nix_run.ron".text = ''
        Config(
          prefix: ":nr ",
          allow_unfree: true,
          channel: "nixos-unstable",
          max_entries: 5,
        )
      '';
      "applications.ron".text = ''
        Config(
          desktop_actions: false,
          max_entries: 5,
        )
      '';
      "symbols.ron".text = ''
        Config(
          max_entries: 10,
        )
      '';
    };
    extraCss = ''
      window {
        background-color: transparent;
        font-family: "Noto Sans";
        font-weight: 500;
        font-size: 11pt;
      }

      entry {
        background-color: #11111b;
        color: #cdd6f4;
        box-shadow: none;
        border-style: solid;
        border-color: rgba(100%, 100%, 100%, 0.05);
        margin-top: 10px;
        margin-bottom: 5px;
      }

      #main {
        background-color: transparent;
      }

      #main > #plugin {
        background-color: #181825;
        border: solid 1px rgba(100%, 100%, 100%, 0.05);
      }

      list {
        background-color: transparent;
        border-radius: 10px;
      }

      row {
        padding: 5px;
        color: rgba(100%, 100%, 100%, 0.5);
        border-radius: 10px;
      }

      row:selected {
        background-color: rgba(100%, 100%, 100%, 0.1);
        color: white;
      }

      row#plugin {
        margin-bottom: 10px;
        padding: 10px;
      }

      #plugin {
        color: rgba(100%, 100%, 100%, 0.8);
      }

    '';
  };
}
