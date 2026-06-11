## Project Overview

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
```

**Checks:**
```bash
# Run all flake checks
nix flake check
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

### AI Agent Tooling

Two tools from `llm-agents.nix` are installed via `config/home/workmux.nix`:
- **workmux** - Git worktree + multiplexer window manager; configured to use WezTerm as its backend (`WORKMUX_BACKEND=wezterm`)
- **herdr** - Terminal workspace manager for AI coding agents
