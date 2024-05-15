local wezterm = require 'wezterm'
local act = wezterm.action

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local zoomed = ''
    if tab.active_pane.is_zoomed then
        zoomed = '[Z] '
    end

    local index = ''
    if #tabs > 1 then
        index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
    end

    return zoomed .. index .. tab.active_pane.title .. ' — wezterm'
end)

return {
    font = wezterm.font '@font@',
    color_scheme = 'Catppuccin Mocha',
    hide_tab_bar_if_only_one_tab = true,
    show_tab_index_in_tab_bar = false,
    window_background_opacity = 0.8,
    enable_scroll_bar = true,
    keys = {
        {
            key = 'Enter',
            mods = 'ALT',
            action = wezterm.action.DisableDefaultAssignment,
        },
    },
    mouse_bindings = {
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'CTRL',
            action = act.IncreaseFontSize,
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'CTRL',
            action = act.DecreaseFontSize,
        },

        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(-5),
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(5),
        },

        --        {
        --            event = { Up = { streak = 1, button = 'Left' } },
        --            mods = 'NONE',
        --            action = act.DisableDefaultAssignment,
        --        },
        --        {
        --            event = { Up = { streak = 1, button = 'Left' } },
        --            mods = 'CTRL',
        --            action = act.OpenLinkAtMouseCursor,
        --        },
        --        -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
        --        {
        --            event = { Down = { streak = 1, button = 'Left' } },
        --            mods = 'CTRL',
        --            action = act.Nop,
        --        },
    },
}
