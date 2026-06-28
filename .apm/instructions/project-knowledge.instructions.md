---
description: Project knowledge for WezTerm, Kitty, and terminal multiplexer Nix configuration
applyTo: "**"
---

# Project Knowledge

## What This Repo Is

A Nix flake that manages two terminal emulator configurations — **WezTerm** (pure Lua) and **Kitty** — plus terminal multiplexers (tmux, zellij, screen). Configuration files live under `emulators/` and are wired into the user's XDG config directory by a home-manager module in `config/`.

## Common Commands

```bash
nix fmt          # Format all Nix (alejandra + deadnix + statix) and Lua (stylua) files
nix flake check  # Run all checks; required before committing
nix develop      # Enter devshell (auto-activated via direnv)
```

There are no tests beyond `nix flake check`. Run it after any change.

## Architecture

### Flake structure

`flake.nix` uses **flake-parts** and **import-tree** to auto-import every `.nix` file under `flake/` and `config/`. Adding a `.nix` file in those directories is enough — no explicit import needed.

```
flake/
  devshells.nix     devshell with nixd, alejandra, stylua; installs pre-commit hooks
  formatters.nix    treefmt config (alejandra, deadnix, statix, stylua)
  checks.nix        pre-commit hooks (trim whitespace, large-file guard, merge-conflict detection…)
  actions/          GitHub Actions workflows via actions-nix
config/
  default.nix       exposes flake.homeManagerConfigurations.{Cfg,default}
  setup.nix         imports config/home via import-tree (the home-manager profile)
  home/             home-manager modules (wezterm.nix, multiplexers/…)
emulators/
  wezterm/          pure-Lua WezTerm config
  kitty/            Kitty conf files
```

### How emulator files reach the system

`config/home/wezterm.nix` explicitly enumerates each Lua filename and maps it to `xdg.configFile."wezterm/<file>"`. It also renders a `colors/cyberpunk.toml` at build time from the shared color palette imported from `OS-nixCfg`. The Lua files themselves are **not** installed via a recursive symlink — each must be listed in the `weztermFiles` list in that module when a new file is added.

### Color scheme coupling

WezTerm's `cyberpunk` color scheme and the `window_background_opacity` value in `emulators/wezterm/options.lua` are derived from `OS-nixCfg/lib/palette.nix`. If opacity changes, update **both** `options.lua` (`config.window_background_opacity`) and the palette. The TOML is rendered automatically by home-manager; never edit `colors/cyberpunk.toml` manually.

Kitty's theme is included via `include current-theme.conf` at the bottom of `kitty.conf`. The active theme name is annotated with `# BEGIN_KITTY_THEME / # END_KITTY_THEME` markers.

### WezTerm Lua module convention

Each Lua module under `emulators/wezterm/` exports a single function `(wezterm, config) -> nil` that mutates the shared `config` table in-place. `wezterm.lua` calls them in order: `options` → `binds` → `smartSplits` → `tabline`.

### Multiplexers

tmux, zellij, and screen are managed as home-manager modules under `config/home/multiplexers/`. tmux is configured entirely through native `programs.tmux` options in `multiplexers/tmux.nix` (typed settings, `programs.tmux.plugins`, and a static status line + bindings in `extraConfig`); `tmux-fzf` is vendored via `mkTmuxPlugin` from the `tmux-fzf` flake input.

## Related Repository

[DivitMittal/OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg) — provides the base16 color palette (`lib/palette.nix`) used by WezTerm's `cyberpunk` color scheme.
