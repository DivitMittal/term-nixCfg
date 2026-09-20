return function(wezterm, config)
  local cmdpicker = wezterm.plugin.require "https://github.com/abidibo/wezterm-cmdpicker"

  -- LEADER+Space is already RotatePanes in binds.lua, and cmdpicker's own
  -- default trigger is that same chord — rebound to LEADER+p. Must be
  -- required last in wezterm.lua: apply_to_config snapshots config.keys at
  -- call time to build the picker's auto-discovered "config bindings"
  -- layer, so every other module's keys need to already be in place.
  cmdpicker.apply_to_config(config, {
    key = "p",
    mods = "LEADER",
    title = "Command Palette",
  })
end
