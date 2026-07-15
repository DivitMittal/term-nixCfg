{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.macos-terminal = {
    enable = true;

    profiles = {
      Basic.settings = {
        FontAntialias = true;
        ShowActiveProcessInTitle = true;
        ShowActiveProcessArgumentsInTitle = false;
        ShowCommandKeyInTitle = false;
        ShowTTYNameInTitle = false;
        columnCount = 220;
        rowCount = 50;
      };
    };
  };
}
