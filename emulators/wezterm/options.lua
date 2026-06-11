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
  -- by OS-nixCfg (home/gui/emulators/wezterm.nix) from lib/palette.nix.
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
  -- Matches stylix.opacity.terminal in OS-nixCfg/lib/palette.nix.
  config.window_background_opacity = 0.85
  config.window_decorations = "RESIZE"
  config.enable_scroll_bar = false

  -- mux server (required for workmux wezterm backend)
  config.unix_domains = { { name = "unix" } }
  config.default_gui_startup_args = { "connect", "unix" }

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
