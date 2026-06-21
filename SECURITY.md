# Security Policy

## Scope

This repo contains Nix configurations for WezTerm, Kitty, and terminal multiplexers (tmux/zellij/screen). It has no servers or network services. The relevant attack surface includes:

- **Terminal emulator configs** that could enable unsafe features (e.g. hyperlink handlers, shell integration that executes arbitrary commands)
- **Nix module options** that install config files into the user's home directory
- **Multiplexer configs** (tmux/zellij) that could run arbitrary commands via keybindings or hooks

## Reporting a Vulnerability

If you find a security issue (e.g. a config option that enables remote code execution via terminal escape sequences, or a module that writes world-readable sensitive files):

1. Open a **GitHub issue** with the label `security`.
2. Include a description, reproduction steps, and impact assessment.

## Out of Scope

- Issues in upstream WezTerm, Kitty, tmux, zellij, or nixpkgs (report upstream)

## Supported Versions

Only the latest commit on `main` is supported.
