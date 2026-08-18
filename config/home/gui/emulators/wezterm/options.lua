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
  -- wezterm/wezterm#7574 (vertical tab bar), patched in via
  -- term-nixCfg's wezterm.nix overlay until it merges upstream.
  config.tab_bar_position = "Left"
  config.tab_bar_width = 200
  -- The fancy tab bar's own container background (the full-height strip
  -- behind the stacked vertical tabs, also used by the horizontal fancy
  -- bar) comes from window_frame.*_titlebar_bg, NOT colors.tab_bar.background
  -- — that field is only read by the classic/retro tab bar renderer, which
  -- vertical positions can't use since they force fancy mode on. Defaults to
  -- an opaque #333333. window_frame is a top-level Config field, not part of
  -- a named color scheme's Palette, so it can't live in cyberpunk.toml —
  -- alpha-matched to window_background_opacity here instead, using the same
  -- base00 (#000000) tab_bar background wezterm.nix renders into the scheme.
  config.window_frame = {
    active_titlebar_bg = "rgba(0, 0, 0, 0.85)",
    inactive_titlebar_bg = "rgba(0, 0, 0, 0.85)",
  }
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
