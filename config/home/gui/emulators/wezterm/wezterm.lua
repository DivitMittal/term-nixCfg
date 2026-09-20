local wezterm = require "wezterm"
local config = wezterm.config_builder()

require "options"(wezterm, config)
require "binds"(wezterm, config)
require "smartSplits"(wezterm, config)
require "sessions"(wezterm, config)
require "workspacePicker"(wezterm, config)
require "agentDeck"(wezterm, config)
require "agentCards"(wezterm, config)
require "stackWez"(wezterm, config)
require "smartSsh"(wezterm, config)
require "quakeTerm"(wezterm, config)
require "tabline"(wezterm, config)
require "cmdPicker"(wezterm, config)

return config
