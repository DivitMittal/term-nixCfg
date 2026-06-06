{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.tmux;
  oh-my-tmux = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "af33f07134b76134acca9d01eacbdecca9c9cda6";
    hash = "sha256-nXm664l84YSwZeRM4Hsweqgz+OlpyfwXcgEdyNGhaGA=";
  };
in {
  options.programs.tmux.oh-my-tmux = {
    enable = lib.mkEnableOption "oh-my-tmux configuration preset";
  };

  config = lib.mkIf cfg.oh-my-tmux.enable {
    xdg.configFile = {
      "tmux/tmux.conf".source = oh-my-tmux + "/.tmux.conf";
      "tmux/tmux.conf.local".source = ./tmux.conf.local;
    };
  };
}
