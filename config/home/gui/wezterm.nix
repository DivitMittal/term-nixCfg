{
  config,
  lib,
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
      # The real nightly build is installed by the `homebrew.casks` entry below
      # (home-manager-brew, real `brew bundle install`) — Homebrew's cask for it
      # sets `sha256 :no_check` (content changes on every nightly build with no
      # version bump), which a Nix fixed-output derivation can never verify, so
      # it can't be built as a Nix package at all (brew-nix's `pkgs.brewCasks`
      # just emits an unbuildable placeholder hash for it). This is only here
      # to satisfy `programs.wezterm`'s package option/`home.packages` entry
      # without shadowing the brew-installed nightly binaries on PATH.
      then pkgs.emptyDirectory
      else pkgs.wezterm;

    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  # Installs the real nightly cask via `brew bundle` at activation (home-manager-brew),
  # sidestepping the Nix fixed-output-hash problem above entirely. Puts the app at
  # /Applications/WezTerm.app and binaries (wezterm, wezterm-gui, wezterm-mux-server)
  # on PATH via Homebrew's own shims once shell integration runs `brew shellenv`.
  # "wezterm" (stable) cask is frozen at the last stable tag (20240203-110809);
  # upstream has shipped only rolling nightlies since, so track those instead to
  # pick up 2+ years of fixes.
  homebrew.casks = lib.optionals pkgs.stdenv.hostPlatform.isDarwin ["wezterm@nightly"];

  # Pre-starts the local-mux unix domain server (options.lua) at login so the
  # socket is already listening and warm before the GUI is ever launched —
  # otherwise wezterm-gui spawns it lazily on first connect, adding a fork +
  # bind to the critical path of opening the terminal. Runs in foreground
  # (no --daemonize) since launchd, not the process itself, owns supervision
  # and restart-on-crash via KeepAlive. Path is the cask's app bundle rather
  # than the Homebrew shim, since the shim's prefix (/usr/local vs
  # /opt/homebrew) depends on host architecture but the app bundle path
  # doesn't.
  launchd.agents.wezterm-mux-server = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = ["/Applications/WezTerm.app/Contents/MacOS/wezterm-mux-server"];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.xdg.cacheHome}/wezterm-mux-server.log";
      StandardErrorPath = "${config.xdg.cacheHome}/wezterm-mux-server.log";
    };
  };

  home.packages = [pkgs.wezterm.terminfo];

  xdg.configFile =
    (builtins.listToAttrs (map
      (file: {
        name = "wezterm/${file}";
        value = {source = ./emulators/wezterm + "/${file}";};
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
