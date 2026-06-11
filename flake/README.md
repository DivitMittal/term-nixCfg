# flake

flake-parts modules auto-imported by `import-tree` from `flake.nix`. Every `.nix` file here is loaded automatically — no registration needed.

- `formatters.nix` — treefmt (alejandra, deadnix, statix, stylua)
- `checks.nix` — pre-commit hooks (whitespace, large files, merge conflicts, private keys)
- `devshells.nix` — dev environment with nixd + alejandra + stylua
- `actions/` — GitHub Actions CI via actions-nix (flake check, lock update)
