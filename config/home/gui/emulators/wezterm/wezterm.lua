local wezterm = require "wezterm"
local config = wezterm.config_builder()

require "options"(wezterm, config)
require "binds"(wezterm, config)
require "smartSplits"(wezterm, config)
require "tabline"(wezterm, config)

-- Windows WezTerm otherwise starts cmd.exe. Scoop installs pwsh on PATH.
if os.getenv("OS") == "Windows_NT" then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

return config
