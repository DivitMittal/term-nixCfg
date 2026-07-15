self: {
  imports = [
    # Emulator profiles only (wezterm, kitty, ghostty, macOS Terminal.app).
    (self.inputs.import-tree ./home/gui)
  ];
}
