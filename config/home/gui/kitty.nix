{
  lib,
  pkgs,
  config,
  base16Scheme,
  ...
}: let
  # Render the cyberpunk base16 theme as kitty color directives, mirroring
  # wezterm/colors/cyberpunk.toml (see config/home/gui/wezterm.nix) so kitty
  # stays in sync with wezterm. ansi/brights follow the canonical base16 →
  # 16-color terminal mapping (base09 → bright yellow, base0F → bright magenta
  # for neon accents).
  hex = name: "#${base16Scheme.${name}}";
  cyberpunkTheme = ''
    background            ${hex "base00"}
    foreground            ${hex "base05"}
    cursor                ${hex "base0C"}
    selection_background  ${hex "base02"}
    selection_foreground  ${hex "base05"}
    color0  ${hex "base00"}
    color1  ${hex "base08"}
    color2  ${hex "base0B"}
    color3  ${hex "base0A"}
    color4  ${hex "base0D"}
    color5  ${hex "base0E"}
    color6  ${hex "base0C"}
    color7  ${hex "base05"}
    color8  ${hex "base03"}
    color9  ${hex "base08"}
    color10 ${hex "base0B"}
    color11 ${hex "base09"}
    color12 ${hex "base0D"}
    color13 ${hex "base0F"}
    color14 ${hex "base0C"}
    color15 ${hex "base07"}
  '';
in {
  programs.kitty = {
    # Off by default — enable per-host in the consumer (OS-nixCfg). Only wezterm
    # is enabled out of the box; kitty & ghostty are kept in sync but opt-in.
    enable = lib.mkDefault false;
    package = pkgs.kitty;

    # The curated emulators/kitty/kitty.conf sets `shell_integration enabled`,
    # so suppress home-manager's auto-injected `shell_integration no-rc` line
    # (and its bash/fish/zsh init snippets) to avoid a duplicate directive.
    shellIntegration.mode = lib.mkDefault null;

    # home-manager writes kitty/kitty.conf unconditionally when enabled, so we
    # cannot also drop a raw file there. Ship the curated config (font, opacity,
    # beam cursor, ctrl+r leader binds — already aligned with wezterm) via
    # extraConfig; its type is `lines`, so it concatenates cleanly with the
    # module's own (here empty) additions.
    extraConfig = builtins.readFile ./emulators/kitty/kitty.conf;
  };

  # Install the rendered theme + launch actions only when kitty is actually on.
  # kitty.conf's `include current-theme.conf` picks up the rendered file below.
  xdg.configFile = lib.mkIf config.programs.kitty.enable {
    "kitty/current-theme.conf".text = cyberpunkTheme;
    "kitty/launch-actions.conf".source = ./emulators/kitty/launch-actions.conf;
  };
}
