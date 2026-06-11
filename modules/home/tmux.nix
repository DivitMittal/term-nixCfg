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
    localConfig = lib.mkOption {
      type = lib.types.path;
      description = "Path to the tmux.conf.local override file";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.oh-my-tmux.enable) {
    # Source oh-my-tmux via extraConfig so programs.tmux manages tmux.conf
    # and conventional HM options (terminal, historyLimit, etc.) can coexist.
    programs.tmux.extraConfig = "source-file ${oh-my-tmux}/.tmux.conf";
    xdg.configFile."tmux/tmux.conf.local".source = cfg.oh-my-tmux.localConfig;
  };
}
