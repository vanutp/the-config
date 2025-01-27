{config, ...}: {
  programs.tofi = {
    enable = true;
    settings = {
      font = config.preferences.font.monospace-path;
      font-size = 13;
      hint-font = false;
      width = 640;
      height = 360;
      text-color = "#cdd6f4";
      prompt-color = "#f38ba8";
      selection-color = "#f9e2af";
      background-color = "#1e1e2e";
      border-width = 2;
      border-color = "#74c7ec";
      outline-width = 0;
      corner-radius = 5;
      padding-left = 16;
      padding-right = 16;
      prompt-text = "\"\"";
    };
  };
}
