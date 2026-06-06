{
  config,
  lib,
  ...
}: let
  cfg = config.programs.zellij;
in {
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enableFishIntegration = false;
      enableZshIntegration = false;
      enableBashIntegration = false;
    };
  };
}
