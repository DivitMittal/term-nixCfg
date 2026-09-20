return function(wezterm, config)
  local workspace_picker = wezterm.plugin.require "https://github.com/isseii10/workspace-picker.wezterm"

  -- LEADER+W/C/R supersede the plain ShowLauncherArgs{WORKSPACES} binding
  -- that used to live in binds.lua: LEADER+W opens the zoxide-backed
  -- picker, LEADER+C creates a workspace manually, LEADER+R renames one.
  -- Uppercase mirrors the lowercase LEADER+w/c/r tab equivalents in
  -- binds.lua (switcher/create/rename), so the two are free to coexist.
  workspace_picker.apply_to_config(config, {
    keybinds = {
      show_picker = { mods = "LEADER", key = "W" },
      create_workspace = { mods = "LEADER", key = "C" },
      rename_workspace = { mods = "LEADER", key = "R" },
    },
  })
end
