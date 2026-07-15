{self, ...}: {
  flake.homeManagerConfigurations = {
    # Terminal-only profile: multiplexers (tmux, zellij, screen, herdr, kolu) + ssh.
    # Imported by OS-nixCfg's tty section (home/tty/imports.nix).
    tty = import ./tty.nix self;
    # GUI/emulator profile: wezterm, kitty, ghostty, macOS Terminal.app.
    # Imported by OS-nixCfg's gui section (home/gui/imports.nix). kitty & ghostty
    # are disabled by default in their modules; enable per-host in the consumer.
    gui = import ./gui.nix self;
  };
}
