---
description: Context for the config/ directory — home-manager modules, wezterm.nix, multiplexers
applyTo: "config/**"
---

## Structure

```
config/
  default.nix        flake output: homeManagerConfigurations.{Cfg, default}
  setup.nix          home-manager profile: import-tree ./home + flake homeManagerModule
  home/
    wezterm.nix      installs WezTerm + renders cyberpunk color scheme
    multiplexers/
      tmux/          tmux via oh-my-tmux, vi keys, mouse enabled
      zellij.nix     zellij (shell integrations all disabled)
      screen.nix     GNU screen
```

## wezterm.nix — Two Important Behaviors

**File enumeration**: Lua files are linked individually, not via a recursive symlink. The `weztermFiles` list must include every file from `emulators/wezterm/` that should appear in `$XDG_CONFIG_HOME/wezterm/`. Adding a new Lua module without updating this list means it won't be installed.

**Color scheme rendering**: `cyberpunk.toml` is generated at home-manager activation time from `OS-nixCfg/lib/palette.nix` (base16). The `hex` helper maps base16 slot names to hex strings. The TOML is written to `$XDG_CONFIG_HOME/wezterm/colors/cyberpunk.toml` and auto-loaded by WezTerm.

On macOS, WezTerm is sourced from `pkgs.brewCasks.wezterm` (Homebrew cask); on Linux it uses `pkgs.wezterm`. Only `pkgs.wezterm.terminfo` is installed system-wide in either case.

## Adding a New Home Module

Drop a `.nix` file anywhere under `config/home/`. The `import-tree` call in `setup.nix` picks it up automatically — no explicit import needed.

## Multiplexers

tmux uses **oh-my-tmux** with its local config override at `tmux/tmux.conf.local`. Settings applied via home-manager options (base index, history limit, key mode, mouse) take effect in the generated tmux.conf that oh-my-tmux sources. Extend tmux behavior by editing `tmux.conf.local`, not `tmux.nix` options.
