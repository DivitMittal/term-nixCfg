self: {
  imports = [
    (self.inputs.import-tree ./home)
    self.homeManagerModules.default
  ];
  _module.args.inputs = self.inputs;
}
