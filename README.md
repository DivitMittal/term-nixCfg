<h1 align='center'>term-nixCfg</h1>
<div align='center'>
    <p></p>
    <div align='center'>
        <a href='https://github.com/DivitMittal/term-nixCfg'>
            <img src='https://img.shields.io/github/repo-size/DivitMittal/term-nixCfg?&style=for-the-badge&logo=github'>
        </a>
        <a href='https://github.com/DivitMittal/term-nixCfg/blob/main/LICENSE'>
            <img src='https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logo=unlicense'/>
        </a>
    </div>
    <br>
</div>

---

<div align='center'>
    <a href="https://github.com/DivitMittal/term-nixCfg/actions/workflows/flake-check.yml">
        <img src="https://github.com/DivitMittal/term-nixCfg/actions/workflows/flake-check.yml/badge.svg" alt="Nix Flake Check"/>
    </a>
    <a href="https://github.com/DivitMittal/term-nixCfg/actions/workflows/flake-lock-update.yml">
        <img src="https://github.com/DivitMittal/term-nixCfg/actions/workflows/flake-lock-update.yml/badge.svg" alt="Update Flake Lock"/>
    </a>
</div>

---
This repository manages terminal emulator and multiplexer configurations as a [Nix flake](https://nixos.wiki/wiki/Flakes), consumed by [OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg) via home-manager.

## Contents

| Directory | Description |
|---|---|
| `emulators/wezterm/` | Pure-Lua [WezTerm](https://github.com/wez/wezterm) config (font, bindings, smart-splits, tabline) |
| `emulators/kitty/` | [Kitty](https://github.com/kovidgoyal/kitty) config and custom theme |
| `config/` | home-manager modules that install the above into `$XDG_CONFIG_HOME` |
| `flake/` | Dev environment, formatters, pre-commit hooks, and CI actions |
| `pkgs/` | nvfetcher-managed external package sources |

Multiplexers managed: **tmux** (native home-manager), **zellij**, **screen**.

## Development

```bash
nix develop   # enter devshell (auto-activated via direnv)
pkgs-update   # refresh nvfetcher-generated package sources
nix fmt       # format Nix (alejandra + deadnix + statix) and Lua (stylua)
nix flake check
```

## For AI Agents

Context files (`AGENTS.md`, `CLAUDE.md`) are generated — not committed. Run `apm compile` before exploring the repo to get directory-level guidance.

## Related Repositories

- [DivitMittal/OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg): Main Nix configurations repository
