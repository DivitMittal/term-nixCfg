## Overview

This repository contains a Lua-based WezTerm terminal emulator configuration for OS-nixCfg. It uses Nix flakes for development environment management and includes pre-commit hooks for code quality.

## Development Environment

This project uses Nix flakes with direnv for automatic environment setup.

### Setup
```bash
# Development environment activates automatically via direnv
# Or manually enter with:
nix develop
```

### Key Commands

**Formatting:**
```bash
# Format all code (Nix and Lua)
nix fmt

# Run specific formatters
alejandra .  # Nix files
stylua .     # Lua files
```

**Checks:**
```bash
# Run all flake checks
nix flake check

# Pre-commit hooks are automatically installed in the devshell
# They run on git commit and check for:
# - Large files
# - Case conflicts
# - Shebang consistency
# - Merge conflicts
# - Private keys
# - Trailing whitespace
```

## Code Architecture

### WezTerm Configuration Structure

The WezTerm configuration is modular, split across multiple Lua files in the `wezterm/` directory:

- **`wezterm.lua`**: Entry point that requires all other modules and returns the configuration table `M`
- **`config.lua`**: Core appearance and behavior settings (font, colors, window settings, hyperlink rules)
- **`binds.lua`**: Key bindings including leader key configuration (CTRL+r), pane splitting, and navigation
- **`smartSplits.lua`**: Integration with smart-splits.nvim plugin for seamless pane navigation (CTRL+Arrow to move, ALT+Arrow to resize)
- **`tabline.lua`**: Custom tab bar using the tabline.wez plugin with Dracula theme, showing mode, workspace, hostname, and domain

### Global Table Convention

All modules contribute to a shared global table `M` which serves as the WezTerm configuration object. The global `W` variable holds the `wezterm` module reference.

### Plugin Integration

Two WezTerm plugins are used:
1. **smart-splits.nvim** - Seamless navigation between WezTerm panes and Neovim splits
2. **tabline.wez** - Enhanced tab bar with custom sections and theming

## Nix Flake Structure

The flake is organized using flake-parts with modules in `flake/`:

- **`devshells.nix`**: Development environment with nixd, alejandra, and stylua
- **`formatters.nix`**: Treefmt configuration with alejandra, deadnix, statix, and stylua
- **`checks.nix`**: Pre-commit hooks configuration using git-hooks.nix
- **`actions/`**: GitHub Actions workflow generation using actions.nix

The flake imports `customLib` from OS-nixCfg for shared utilities.

## Code Style

### Lua
- 2 space indentation
- Unix line endings
- 120 character line width
- No parentheses for function calls (StyLua setting: `call_parentheses = "None"`)
- Auto-prefer double quotes

### Nix
- Formatted with alejandra
- Checked with deadnix (dead code) and statix (lints)

## Key Bindings Reference

- **Leader key**: CTRL+r
- **LEADER+s**: Split vertically
- **LEADER+v**: Split horizontally
- **LEADER+5**: Toggle pane zoom
- **LEADER+Space**: Rotate panes clockwise
- **LEADER+f**: Search
- **LEADER+Enter**: Activate copy mode
- **CTRL+Arrow**: Navigate between panes (via smart-splits)
- **ALT+Arrow**: Resize panes (via smart-splits)
- **SHIFT+Enter**: Send ESC+Enter to terminal
