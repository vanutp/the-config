{...}: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        frame_color = "#89B4FA";
        separator_color = "frame";
        corner_radius = 5;
      };

      urgency_low = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_normal = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_critical = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#FAB387";
      };
    };
  };
}
