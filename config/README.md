# config

Home-manager configuration that wires the emulator files into the system.

- `default.nix` — exposes `flake.homeManagerConfigurations.{Cfg, default}`
- `setup.nix` — profile entrypoint: imports `home/` via import-tree
- `home/` — per-program home-manager modules; any `.nix` dropped here is picked up automatically

Programs managed here: WezTerm, tmux (native home-manager), zellij, screen.
