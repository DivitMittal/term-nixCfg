return function(wezterm, config)
  local act = wezterm.action

  -- Leader is Ctrl+b: matches the classic tmux default prefix and frees
  -- Ctrl+r for shell reverse-i-search (the escape hatch below forwards
  -- a literal Ctrl+b when you genuinely need it).
  config.leader = {
    mods = "CTRL",
    key = "b",
    timeout_milliseconds = 800,
  }
  config.keys = {
    {
      mods = "ALT",
      key = "Enter",
      action = act.DisableDefaultAssignment,
    },
    -- Send ESC+Enter when pressing Shift+Enter
    {
      mods = "SHIFT",
      key = "Enter",
      action = act.SendString "\x1b\r",
    },
    -- Send Ctrl+b to the terminal when pressing LEADER, LEADER
    {
      mods = "LEADER|CTRL",
      key = "b",
      action = act.SendKey { mods = "CTRL", key = "b" },
    },

    -- splitting
    {
      mods = "LEADER",
      key = "s",
      action = act.SplitVertical { domain = "CurrentPaneDomain" },
    },

    {
      mods = "LEADER",
      key = "v",
      action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
    },

    -- maximize a single pane
    {
      mods = "LEADER",
      key = "5",
      action = act.TogglePaneZoomState,
    },

    -- rotate panes
    {
      mods = "LEADER",
      key = "Space",
      action = act.RotatePanes "Clockwise",
    },

    -- show the pane selection mode, but have it swap the active and selected panes
    {
      mods = "LEADER",
      key = "f",
      action = act.Search { CaseInSensitiveString = "" },
    },

    -- activate copy mode or vim mode
    {
      mods = "LEADER",
      key = "Enter",
      action = act.ActivateCopyMode,
    },

    -- workspace chooser
    {
      mods = "LEADER",
      key = "w",
      action = act.ShowLauncherArgs { flags = "WORKSPACES" },
    },

    -- C-S-l activates the debug overlay (implemented by default)
  }
end
