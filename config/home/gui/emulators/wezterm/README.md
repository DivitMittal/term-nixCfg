# emulators/wezterm

Pure-Lua [WezTerm](https://wezfurlong.org/wezterm/) configuration.

| File | Role |
|---|---|
| `wezterm.lua` | Entry point — requires and calls all other modules |
| `options.lua` | Font, appearance, opacity, hyperlink rules, mux domain |
| `binds.lua` | Leader key (`CTRL+r`) and all key bindings |
| `smartSplits.lua` | [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) plugin config |
| `tabline.lua` | [tabline.wez](https://github.com/michaelbrusegard/tabline.wez) plugin config |

These files are symlinked into `$XDG_CONFIG_HOME/wezterm/` by the home-manager module at `config/home/wezterm.nix`. The `cyberpunk` color scheme TOML is generated separately by that module from the shared OS-nixCfg palette — it does not live here.
