{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default import for all modules
    default = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [
        (inputs.import-tree ./home)
        (inputs.import-tree ../config/home)
      ];
    };

    ## Individual imports (for selective usage)
    tmux = import ./home/multiplexers/tmux/tmux.nix;
    zellij = import ../config/home/multiplexers/zellij.nix;
    screen = import ../config/home/multiplexers/screen.nix;
  };
}
