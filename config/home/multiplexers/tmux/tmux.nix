{...}: {
  programs.tmux.oh-my-tmux = {
    enable = true;
    localConfig = ./tmux.conf.local;
  };
}
