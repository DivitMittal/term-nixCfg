---
description: Context for the flake/ directory — formatters, checks, devshell, CI actions
applyTo: "flake/**"
---

## Import Convention

`flake.nix` calls `import-tree ./flake`, so every `.nix` file here is automatically imported as a flake-parts module. No registration is needed when adding a file.

## Files

| File | Purpose |
|---|---|
| `formatters.nix` | treefmt: alejandra + deadnix + statix (Nix), stylua (Lua). `flakeCheck = false` — formatting is not a blocking check, but `nix fmt` must be run before committing. |
| `checks.nix` | pre-commit hooks via git-hooks.nix: trim whitespace, large-file guard, case conflicts, merge-conflict markers, private key detection. Hook package is `pkgs.prek`. |
| `devshells.nix` | Default devshell with nixd, alejandra, stylua. Installs pre-commit hooks automatically on `devshell.startup`. |
| `actions/common.nix` | Shared GitHub Actions primitives (checkout, Nix install, cache). Triggers on pushes/PRs to `main` that touch `flake.nix`, `flake.lock`, or `flake/**`. |
| `actions/flake-check.nix` | CI job: runs `nix flake check`. |
| `actions/flake-lock-update.nix` | CI job: automated flake lock updates. |

## Formatters Detail

`statix` lints for anti-patterns (e.g. `with` scopes, unnecessary `rec`). `deadnix` removes unused bindings. Both run as part of `nix fmt` — fix their findings before committing.
