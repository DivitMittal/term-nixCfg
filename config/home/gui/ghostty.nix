{
  lib,
  base16Scheme,
  ...
}: let
  # base16 → 16-color ordering, identical to wezterm/colors/cyberpunk.toml
  # (see config/home/gui/wezterm.nix) and kitty/current-theme.conf. base09 →
  # bright yellow, base0F → bright magenta for neon accents.
  slots = [
    "base00" # 0  black
    "base08" # 1  red
    "base0B" # 2  green
    "base0A" # 3  yellow
    "base0D" # 4  blue
    "base0E" # 5  magenta
    "base0C" # 6  cyan
    "base05" # 7  white
    "base03" # 8  bright black
    "base08" # 9  bright red
    "base0B" # 10 bright green
    "base09" # 11 bright yellow → neon orange
    "base0D" # 12 bright blue
    "base0F" # 13 bright magenta → neon violet
    "base0C" # 14 bright cyan
    "base07" # 15 bright white
  ];
  # ghostty palette lines want `N=#RRGGBB`; the solid color fields take bare hex.
  bare = name: base16Scheme.${name};
  tagged = name: "#${base16Scheme.${name}}";
in {
  programs.ghostty = {
    enable = lib.mkDefault false;

    settings = {
      # ── appearance (mirror wezterm options.lua) ──
      font-family = "CaskaydiaCove NFM"; # wezterm: CaskaydiaCove Nerd Font Mono
      font-size = 20; # wezterm: config.font_size
      background-opacity = 0.85; # wezterm: window_background_opacity (== palette.opacity.terminal)
      cursor-style = "bar"; # wezterm: SteadyBar
      cursor-style-blink = false;
      window-padding-x = 0; # wezterm: window_padding = {0,0,0,0}
      window-padding-y = 0;
      mouse-hide-while-typing = true;
      link-url = true; # wezterm: hyperlink_rules

      # Consume the custom theme rendered below from the shared base16 palette.
      theme = "cyberpunk";

      # ── leader = ctrl+r, mirroring wezterm binds.lua where ghostty has an
      #    equivalent action. Sequences use `>`; text bytes use Zig \xNN escapes.
      keybind = [
        "ctrl+r>ctrl+r=text:\\x12" # LEADER,LEADER → send literal Ctrl+r (0x12)
        "ctrl+r>s=new_split:down" # LEADER s → split vertical   (wezterm SplitVertical)
        "ctrl+r>v=new_split:right" # LEADER v → split horizontal (wezterm SplitHorizontal)
        "ctrl+r>5=toggle_split_zoom" # LEADER 5 → zoom a single pane (wezterm TogglePaneZoomState)
      ];
    };

    # cyberpunk base16 theme, generated from the same palette as wezterm/kitty.
    # home-manager writes this to $XDG_CONFIG_HOME/ghostty/themes/cyberpunk.
    themes.cyberpunk = {
      palette = lib.imap0 (i: slot: "${toString i}=${tagged slot}") slots;
      background = bare "base00";
      foreground = bare "base05";
      cursor-color = bare "base0C";
      selection-background = bare "base02";
      selection-foreground = bare "base05";
    };
  };
}
