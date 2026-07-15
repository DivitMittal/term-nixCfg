{pkgs, ...}: {
  home.packages = [pkgs.byobu];

  xdg.configFile = {
    "byobu/backend".text = ''
      BYOBU_BACKEND=tmux
    '';

    "byobu/status".text = ''
      # Keep Byobu's status portable across Darwin and Linux.
      tmux_left="session"
      tmux_right="load_average memory date time"
    '';

    "byobu/statusrc".text = ''
      TIME="%H:%M"
      DATE="%Y-%m-%d"
    '';

    "byobu/profile.tmux".text = ''
      # Align Byobu's tmux backend with the repo's direct tmux defaults.
      set -g mouse on
      set -g history-limit 50000
      set -g status-position top
      set -ga terminal-overrides ",*256col*:Tc"
      set -g allow-passthrough on
    '';
  };
}
