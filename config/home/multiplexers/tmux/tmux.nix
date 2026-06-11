{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;

    baseIndex = 1;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";

    oh-my-tmux = {
      enable = true;
      localConfig = ./tmux.conf.local;
    };
  };
}
