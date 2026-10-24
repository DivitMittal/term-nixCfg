self: {lib, ...}: {
  imports = [
    # Emulator profiles only (wezterm, kitty, ghostty, macOS Terminal.app).
    (self.inputs.import-tree ./home/gui)
  ];

  # Same as tty.nix's (see there for why it isn't `inputs`). mkDefault so that
  # importing both profiles doesn't define this raw arg twice at one priority.
  _module.args.termInputs = lib.mkDefault self.inputs;
}
