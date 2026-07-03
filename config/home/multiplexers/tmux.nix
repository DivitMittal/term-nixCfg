{
  pkgs,
  lib,
  termInputs,
  ...
}: let
  clipCmd =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "pbcopy"
    else "wl-copy";

  tmux-fzf = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-fzf";
    rtpFilePath = "main.tmux";
    version = "0-unstable-2025-09-24";
    src = termInputs.tmux-fzf;
    meta = {
      homepage = "https://github.com/sainnhe/tmux-fzf";
      description = "Tmux key bindings for fzf";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };
in {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;

    # ── core settings
    terminal = "tmux-256color";
    baseIndex = 1; # windows and panes numbered from 1
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    prefix = "C-a";
    focusEvents = true;
    sensibleOnTop = true; # tmux-sensible defaults, sourced first
    customPaneNavigationAndResize = true; # prefix h/j/k/l + H/J/K/L resize
    resizeAmount = 5;

    # ── plugins
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      # prefix+C-s save, prefix+C-r restore
      jump
      # prefix+j regex jump
      open
      # prefix+o highlight/open URLs
      tmux-fzf # prefix+F fzf session/window/pane picker
    ];

    extraConfig = ''
      # ── truecolor / terminal behaviour ──
      set -ga terminal-overrides ",*256col*:Tc"
      set -g allow-passthrough on
      set -ga update-environment "TERM TERM_PROGRAM"

      # ── prefix is C-a exclusively (set via home-manager option above) ──
      unbind C-b

      # ── status line (static rewrite of the green/yellow oh-my-tmux theme) ──
      set -g status-position top
      set -g status-style "bg=default,fg=#e4e4e4"
      set -g status-left "#[fg=#080808,bg=#ffff00,bold] ❐ #S "
      set -g status-right "#[fg=#ffffff,bg=#d70000] #(whoami) #[fg=#080808,bg=#e4e4e4] #H "
      set -g window-status-format " #I #W "
      set -g window-status-current-format " #I #W "
      set -g window-status-current-style "fg=#000000,bg=#00ff00,bold"
      set -g status-left-length 40
      set -g status-right-length 80

      # ── splits (vim-style) ──
      bind v split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── misc ──
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded"

      # ── copy mode: v begin selection, y yank to OS clipboard ──
      set -g set-clipboard on
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${clipCmd}"
    '';
  };
}
