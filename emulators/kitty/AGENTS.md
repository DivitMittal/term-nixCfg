# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Files

- `kitty.conf` — main config; uses vim fold markers (`{{{`/`}}}`) for sections
- `current-theme.conf` — color theme included at the bottom of `kitty.conf` via `include current-theme.conf`; managed by `kitty +kitten themes`
- `launch-actions.conf` — protocol handlers: opens text files in `$EDITOR`, images with `icat` kitten

## Notable Non-Default Settings

| Setting | Value | Why |
|---|---|---|
| `macos_option_as_alt` | `yes` | Enables `Alt+key` shortcuts in terminal programs |
| `background_opacity` | `0.8` | Compositor transparency |
| `hide_window_decorations` | `titlebar-only` | macOS titlebar hidden, resize border kept |
| `shell_integration` | `enabled` | Cursor shape at prompt, jump-to-prompt, command output browsing |
| `cursor_blink_interval` | `0` | Blinking disabled |
| `input_delay` | `1` | Reduced from default 3 ms for lower latency |

## Theme Management

The active theme sits between `# BEGIN_KITTY_THEME` / `# END_KITTY_THEME` markers at the bottom of `kitty.conf`. To change theme: `kitty +kitten themes` (rewrites `current-theme.conf` and updates the markers). Do not manually edit `current-theme.conf`.

Kitty's color scheme is **not** derived from `OS-nixCfg/lib/palette.nix` — it is managed independently from WezTerm's `cyberpunk` scheme.
