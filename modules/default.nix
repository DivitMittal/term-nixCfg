{inputs, ...}: {
  flake.homeManagerModules = let
    # Defined inline to close over TermEmulator-Cfg's inputs.llm-agents,
    # since import-tree modules don't receive flake inputs as arguments.
    workmux = {pkgs, ...}: {
      home.packages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux
      ];
    };
  in {
    ## Default import for all modules
    default = {
      imports = [
        (inputs.import-tree ./home)
        (inputs.import-tree ../config/home)
        workmux
      ];
    };

    ## Individual imports (for selective usage)
    tmux = import ./home/multiplexers/tmux/tmux.nix;
    zellij = import ../config/home/multiplexers/zellij.nix;
    screen = import ../config/home/multiplexers/screen.nix;
    inherit workmux;
  };
}
