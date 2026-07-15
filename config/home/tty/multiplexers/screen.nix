{pkgs, ...}: {
  programs.screen = {
    enable = true;
    package = pkgs.screen;

    screenrc = ''
      # GNU Screen run commands configuration
      # the following two lines give a two-line status, with the current window highlighted
      hardstatus alwayslastline
      hardstatus string '%{= kG}[%{G}%H%? %1`%?%{g}][%= %{= kw}%-w%{+b yk} %n*%t%?(%u)%? %{-}%+w %=%{g}][%{B}%m/%d %{W}%C%A%{g}]'

      # huge scrollback buffer (matches tmux's historyLimit = 50000)
      defscrollback 50000

      # no welcome message
      startup_message off

      # 256 colors
      attrcolor b ".I"
      termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'
      defbce on
      term screen-256color

      # mouse tracking allows to switch region focus by clicking
      mousetrack on

      # default windows
      screen -t shell  1 fish
      select 0
      bind c screen # new window in the next free slot
      bind 0 select 10

      # get rid of silly xoff stuff
      bind s split

      # layouts
      layout autosave on
      layout new one
      select 1
      layout new two
      select 1
      split
      resize -v +8
      focus down
      select 4
      focus up
      layout new three
      select 1
      split
      resize -v +7
      focus down
      select 3
      split -v
      resize -h +10
      focus right
      select 4
      focus up

      layout attach one
      layout select one

      # inner-mux heuristic: tab/window actions
      bind d kill
      bind n next
      bind p prev
      bind 1 select 1
      bind 2 select 2
      bind 3 select 3
      bind 4 select 4
      bind 5 select 5
      bind 6 select 6
      bind 7 select 7
      bind 8 select 8
      bind 9 select 9

      # quickly switch between regions using prefix + tab/arrows
      bind -c rsz \t    eval "focus"       "command -c rsz" # Tab
      bind -c rsz -k kl eval "focus left"  "command -c rsz" # Left
      bind -c rsz -k kr eval "focus right" "command -c rsz" # Right
      bind -c rsz -k ku eval "focus up"    "command -c rsz" # Up
      bind -c rsz -k kd eval "focus down"  "command -c rsz" # Down
      bind -k kl focus left
      bind -k kr focus right
      bind -k ku focus up
      bind -k kd focus down

      # ── alt+ navigation layer (prefix-free) ──
      # Screen has no root key table, so Alt+letters are bound as raw escape
      # sequences (M-c = ESC c). Bare Alt+Arrow stays owned by WezTerm +
      # smart-splits.nvim (resize), so letters are used. Screen has no
      # workspace/session scope, so the shift-letter set is omitted here.
      bindkey "\Ec" screen      # new window
      bindkey "\Ed" kill        # kill window
      bindkey "\En" next        # next window
      bindkey "\Ep" prev        # prev window
      bindkey "\E1" select 1
      bindkey "\E2" select 2
      bindkey "\E3" select 3
      bindkey "\E4" select 4
      bindkey "\E5" select 5
      bindkey "\E6" select 6
      bindkey "\E7" select 7
      bindkey "\E8" select 8
      bindkey "\E9" select 9
    '';
  };
}
