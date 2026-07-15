{pkgs, ...}: {
  home.packages = with pkgs; [
    eternal-terminal
    mosh
  ];

  home.sessionVariables = {
    MOSH_ESCAPE_KEY = "^]";
    MOSH_TITLE_NOPREFIX = "1";
  };
}
