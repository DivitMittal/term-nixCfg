{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # OS clipboard command for copy-mode yank.
  clipCmd =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "pbcopy"
    else "wl-copy";

  # tmux-fzf has no nixpkgs package; vendor it from the flake input so the source
  # is lock-managed and bumps with `nix flake update`. Its `main.tmux` entrypoint
  # self-locates via BASH_SOURCE and binds prefix+F, so it runs cleanly from the
  # Nix store under home-manager's run-shell (no tpm required).
  tmux-fzf = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-fzf";
    rtpFilePath = "main.tmux";
    version = "0-unstable-2025-09-24";
    src = inputs.tmux-fzf;
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

    # ── core settings (these are now authoritative, not overridden by oh-my-tmux) ──
    terminal = "tmux-256color";
    baseIndex = 1; # windows and panes numbered from 1
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    focusEvents = true;
    sensibleOnTop = true; # tmux-sensible defaults, sourced first
    customPaneNavigationAndResize = true; # prefix h/j/k/l + H/J/K/L resize
    resizeAmount = 5;

    # ── plugins (declarative; replaces oh-my-tmux's tpm loader) ──
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      jump
      open
      tmux-fzf # binds prefix+F itself
    ];

    extraConfig = ''
      # ── truecolor / terminal behaviour ──
      set -ga terminal-overrides ",*256col*:Tc"
      set -g allow-passthrough on
      set -ga update-environment "TERM TERM_PROGRAM"

      # ── keep both prefixes (oh-my-tmux added C-a as a second prefix) ──
      set -g prefix2 C-a
      bind C-a send-prefix -2

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

      # ── bindings ported from the former tmux.conf.local ──
      bind n new-session
      unbind c
      bind t new-window -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind Tab next-window
      bind BTab previous-window
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded"

      # ── copy mode + OS clipboard ──
      set -g set-clipboard on
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${clipCmd}"
    '';
  };
}
