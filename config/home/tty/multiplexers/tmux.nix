{
  pkgs,
  lib,
  base16Scheme,
  ...
}: let
  sources = pkgs.callPackage ../../../../pkgs/_sources/generated.nix {};

  # Map a base16 slot name (e.g. "base0C") to a "#RRGGBB" tmux color.
  # Same palette source as wezterm/colors/cyberpunk.toml (home/wezterm.nix)
  # and the zellij `cyberpunk` theme — keeps tmux chrome in sync with the
  # rest of the terminal stack.
  hex = name: "#${base16Scheme.${name}}";

  clipCmd =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "pbcopy"
    else "wl-copy";

  tmux-fzf = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-fzf";
    rtpFilePath = "main.tmux";
    version = "0-unstable-${sources.tmux-fzf.date}";
    src = sources.tmux-fzf.src;
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
    customPaneNavigationAndResize = false; # avoid qwerty hjkl/HJKL bindings
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

    # lib.mkAfter so these `set -g` values win over the base16 styles stylix's
    # tinted-tmux target sources (status-style bg=base00, …); tinted-tmux's
    # non-status chrome (pane borders, message, clock) still applies.
    extraConfig = lib.mkAfter ''
      # ── truecolor / terminal behaviour ──
      set -ga terminal-overrides ",*256col*:Tc"
      set -g allow-passthrough on
      set -ga update-environment "TERM TERM_PROGRAM"

      # ── prefix is C-a exclusively (set via home-manager option above) ──
      unbind C-b

      # ── status line (cyberpunk base16, aligned with wezterm/zellij) ──
      # Colors come from the shared base16Scheme via `hex` — same source as
      # wezterm/colors/cyberpunk.toml and the zellij `cyberpunk` theme. Cyan
      # (base0C) is the active accent, mirroring wezterm's active tab
      # (bg=base02, fg=base0C) and zellij's ribbon_selected. `bg=default` keeps
      # the bar compositing through wezterm's 0.85 window opacity.
      set -g status-position top
      set -g status-style "bg=default,fg=${hex "base05"}"
      set -g window-status-style "bg=default,fg=${hex "base04"}"
      set -g window-status-current-style "bg=${hex "base02"},fg=${hex "base0C"},bold"
      set -g window-status-separator ""
      set -g status-left "#[fg=${hex "base0C"},bg=${hex "base02"},bold] ❐ #S "
      set -g status-right "#[fg=${hex "base04"}]#(whoami)@#H "
      set -g window-status-format "#[fg=${hex "base04"}] #I #W "
      set -g window-status-current-format "#[fg=${hex "base0C"},bg=${hex "base02"},bold] #I #W #[default]"
      set -g status-left-length 40
      set -g status-right-length 80

      # ── splits ──
      bind v split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── inner-mux heuristic: tab/window actions ──
      # Bare Ctrl/Alt arrows are reserved for WezTerm + smart-splits.nvim.
      unbind-key -q ,
      unbind-key -q &
      unbind-key -q C-n
      unbind-key -q C-p
      bind c new-window -c "#{pane_current_path}"
      bind r command-prompt -I "#W" "rename-window %%"
      bind d kill-window
      bind n next-window
      bind p previous-window

      # ── inner-mux heuristic: workspace/session actions ──
      bind C new-session
      bind R command-prompt -I "#S" "rename-session %%"
      bind D kill-session
      bind N switch-client -n
      bind P switch-client -p

      # ── inner-mux heuristic: indexed tab/window jump (1-9, 0 → 10) ──
      bind 1 select-window -t :1
      bind 2 select-window -t :2
      bind 3 select-window -t :3
      bind 4 select-window -t :4
      bind 5 select-window -t :5
      bind 6 select-window -t :6
      bind 7 select-window -t :7
      bind 8 select-window -t :8
      bind 9 select-window -t :9
      bind 0 select-window -t :10

      # ── inner-mux heuristic: prefix + plain arrows for panes ──
      bind Left select-pane -L
      bind Down select-pane -D
      bind Up select-pane -U
      bind Right select-pane -R

      # ── alt+ navigation layer (prefix-free) ──
      # Mirrors the prefix mnemonic scheme but without needing C-a, so tab and
      # workspace switching are one chord. Bare Alt+Arrow stays owned by
      # WezTerm + smart-splits.nvim (resize), so letters are used here.
      bind -n M-c new-window -c "#{pane_current_path}"
      bind -n M-r command-prompt -I "#W" "rename-window %%"
      bind -n M-d kill-window
      bind -n M-n next-window
      bind -n M-p previous-window
      bind -n M-1 select-window -t :1
      bind -n M-2 select-window -t :2
      bind -n M-3 select-window -t :3
      bind -n M-4 select-window -t :4
      bind -n M-5 select-window -t :5
      bind -n M-6 select-window -t :6
      bind -n M-7 select-window -t :7
      bind -n M-8 select-window -t :8
      bind -n M-9 select-window -t :9
      bind -n M-0 select-window -t :10
      bind -n M-C new-session
      bind -n M-R command-prompt -I "#S" "rename-session %%"
      bind -n M-D kill-session
      bind -n M-N switch-client -n
      bind -n M-P switch-client -p

      # ── misc ──
      # C-r reloads ~/.config/tmux/tmux.conf (which re-sources tmux.conf.local
      # via oh-my-tmux). F5 was the previous choice but WezTerm can intercept
      # function keys, silently killing the binding.
      bind C-r source-file ~/.config/tmux/tmux.conf \; display "Reloaded"

      # ── copy mode: v begin selection, y yank to OS clipboard ──
      set -g set-clipboard on
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "${clipCmd}"
    '';
  };
}
