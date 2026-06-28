self: {
  imports = [
    (self.inputs.import-tree ./home)
  ];
  _module.args.inputs = self.inputs;
}
