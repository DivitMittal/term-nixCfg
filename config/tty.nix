self: {
  imports = [
    (self.inputs.import-tree ./home/tty)
    self.inputs.kolu.homeManagerModules.default
  ];

  # Expose THIS flake's inputs under a non-standard name. Consumers (e.g. OS-nixCfg)
  # pass `extraSpecialArgs.inputs` (their own inputs), which would shadow/conflict with
  # a `_module.args.inputs` here — so any term-nixCfg-specific input reachable only via
  # `inputs` (like the `tmux-fzf` flake input) would vanish. Using `termInputs` keeps our
  # own inputs reachable regardless of how the module is consumed.
  _module.args.termInputs = self.inputs;
}
