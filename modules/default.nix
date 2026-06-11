{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default import for all modules
    default = {
      imports = [(inputs.import-tree ./home)];
    };

    ## Individual imports (for selective usage)
    tmux = import ./home/tmux.nix;
  };
}
