{
  pkgs,
  base16Scheme,
  ...
}: let

  # Render a wezterm color scheme TOML from the shared palette.
  # See https://wezterm.org/config/appearance.html#defining-your-own-colors
  # for the schema. ansi[0..7] / brights[0..7] follow the canonical
  # base16 → 16-color terminal mapping.
  hex = name: "#${base16Scheme.${name}}";
  cyberpunkToml = ''
    [colors]
    foreground      = "${hex "base05"}"
    background      = "${hex "base00"}"
    cursor_bg       = "${hex "base0C"}"
    cursor_fg       = "${hex "base00"}"
    cursor_border   = "${hex "base0C"}"
    selection_fg    = "${hex "base05"}"
    selection_bg    = "${hex "base02"}"
    scrollbar_thumb = "${hex "base02"}"
    split           = "${hex "base03"}"

    ansi = [
      "${hex "base00"}",  # black
      "${hex "base08"}",  # red
      "${hex "base0B"}",  # green
      "${hex "base0A"}",  # yellow
      "${hex "base0D"}",  # blue
      "${hex "base0E"}",  # magenta
      "${hex "base0C"}",  # cyan
      "${hex "base05"}",  # white
    ]
    brights = [
      "${hex "base03"}",  # bright black (comments)
      "${hex "base08"}",  # bright red
      "${hex "base0B"}",  # bright green
      "${hex "base09"}",  # bright yellow → neon orange for contrast
      "${hex "base0D"}",  # bright blue
      "${hex "base0F"}",  # bright magenta → neon violet
      "${hex "base0C"}",  # bright cyan
      "${hex "base07"}",  # bright white
    ]

    [colors.tab_bar]
    background          = "${hex "base00"}"
    inactive_tab_edge   = "${hex "base02"}"

    [colors.tab_bar.active_tab]
    bg_color = "${hex "base02"}"
    fg_color = "${hex "base0C"}"

    [colors.tab_bar.inactive_tab]
    bg_color = "${hex "base01"}"
    fg_color = "${hex "base04"}"

    [colors.tab_bar.inactive_tab_hover]
    bg_color = "${hex "base02"}"
    fg_color = "${hex "base05"}"
    italic   = true

    [colors.tab_bar.new_tab]
    bg_color = "${hex "base01"}"
    fg_color = "${hex "base0C"}"
  '';

  # We enumerate files individually (instead of a recursive symlink tree) so
  # the nix-generated colors/cyberpunk.toml can coexist without conflicts.
  weztermFiles = ["binds.lua" "options.lua" "smartSplits.lua" "tabline.lua" "wezterm.lua"];
in {
  programs.wezterm = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.brewCasks.wezterm
      else pkgs.wezterm;

    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  home.packages = [pkgs.wezterm.terminfo];

  xdg.configFile =
    (builtins.listToAttrs (map
      (file: {
        name = "wezterm/${file}";
        value = {source = ../../emulators/wezterm + "/${file}";};
      })
      weztermFiles))
    // {
      # Wezterm autoloads color schemes from $XDG_CONFIG_HOME/wezterm/colors/*.toml.
      # Referenced by `config.color_scheme = "cyberpunk"` in options.lua.
      # NOTE: window opacity is mirrored in upstream options.lua; keep it in
      # sync with OS-nixCfg lib/palette.nix `opacity.terminal` (currently 0.85).
      "wezterm/colors/cyberpunk.toml".text = cyberpunkToml;
    };
}
