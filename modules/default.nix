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
        workmux
      ];
    };

    ## Individual imports (for selective usage)
    tmux = import ./home/multiplexers/tmux/tmux.nix;
    zellij = import ./home/multiplexers/zellij.nix;
    screen = import ./home/multiplexers/screen.nix;
    inherit workmux;
  };
}
