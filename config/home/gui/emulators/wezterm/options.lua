return function(wezterm, config)
  config.term = "wezterm"
  config.enable_kitty_graphics = true

  -- font
  config.font = wezterm.font "CaskaydiaCove Nerd Font Mono"
  config.font_size = 20
  config.adjust_window_size_when_changing_font_size = false
  config.custom_block_glyphs = false
  config.harfbuzz_features = {
    "calt=1",
    "clig=1",
    "liga=1",
  }

  -- appearance
  config.window_close_confirmation = "AlwaysPrompt"
  -- Color scheme is rendered into $XDG_CONFIG_HOME/wezterm/colors/cyberpunk.toml
  -- by config/home/gui/wezterm.nix (consuming the base16Scheme from
  -- OS-nixCfg/lib/palette.nix).
  config.color_scheme = "cyberpunk"
  config.default_cursor_style = "SteadyBar"
  config.initial_cols = 100
  config.initial_rows = 40
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
  config.native_macos_fullscreen_mode = false

  -- Local unix-domain mux server: panes survive a WezTerm GUI crash/quit
  -- and are recovered when it's relaunched (a host reboot still loses
  -- them). default_gui_startup_args makes the default launch attach to
  -- this domain instead of a GUI-local-only pty. Pair with sessions.lua
  -- (wezterm-sessions) for save/restore across a full restart.
  -- "local" is a reserved built-in domain name and cannot be redefined.
  config.unix_domains = {
    { name = "local-mux" },
  }
  config.default_gui_startup_args = { "connect", "local-mux" }
  -- The mux protocol renders panes via server-side screen diffs rather than
  -- a raw pty passthrough, so fast full-redraw TUIs (btop, yazi) can arrive
  -- as partial frames and show stale/garbled state. Bumping this batches
  -- pty reads into more complete frames before diffing (default 3ms).
  config.mux_output_parser_coalesce_delay_ms = 15
  -- Matches stylix.opacity.terminal in OS-nixCfg/lib/palette.nix.
  config.window_background_opacity = 0.85
  config.window_decorations = "RESIZE"
  config.enable_scroll_bar = false
  config.max_fps = 60
  config.animation_fps = 1
  config.front_end = "WebGpu"
  config.webgpu_power_preference = "HighPerformance"
  config.check_for_updates = false
  config.scrollback_lines = 1000

  -- hyperlink
  config.hyperlink_rules = {
    {
      regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
      format = "$0",
    },
    {
      regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
      format = "mailto:$0",
    },
    {
      regex = [[\bfile://\S*\b]],
      format = "$0",
    },
    {
      regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
      format = "$0",
    },
    {
      regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
      format = "https://www.github.com/$1/$3",
    },
  }
end
