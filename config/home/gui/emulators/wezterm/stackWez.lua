return function(wezterm, config)
  local stack = wezterm.plugin.require "https://github.com/bad-noodles/stack.wez"

  -- enrich_tab_title disabled: stack.wez's built-in format-tab-title hook
  -- would lose the same handler-registration race against tabline.lua that
  -- agent-deck did (tabline.lua loads last and owns that event).
  -- tabline.lua composes stack.stack_info() into its own tab components
  -- instead. apply_to_config ignores its config argument entirely — it
  -- only stores opts and doesn't touch config.keys, so keybindings are
  -- added directly below via stack.action.*.
  stack.apply_to_config(config, {
    enrich_tab_title = false,
  })

  config.keys = config.keys or {}

  -- New stacked pane, and step through the stack while staying zoomed.
  -- Closing uses WezTerm's built-in CloseCurrentPane (already bound by
  -- default) — stack.wez has no API for closing while preserving zoom.
  -- LEADER+c claims the slot that would otherwise mirror LEADER+t
  -- (tab create) — see the note in binds.lua's tab section.
  table.insert(config.keys, { mods = "LEADER", key = "c", action = stack.action.SpawnPane })
  table.insert(config.keys, { mods = "LEADER", key = "u", action = stack.action.ActivatePaneRelative(-1) })
  table.insert(config.keys, { mods = "LEADER", key = "e", action = stack.action.ActivatePaneRelative(1) })

  -- Fuzzy switcher across the active tab's panes (type to filter), for
  -- when a stack has grown past a few panes and u/e stepping is too slow.
  -- stack.wez has no picker of its own, so this is built directly on
  -- InputSelector; it re-zooms afterward the same way
  -- ActivatePaneRelative does, so it works whether or not the tab was
  -- already zoomed into the stack.
  table.insert(config.keys, {
    mods = "LEADER",
    key = "a",
    action = wezterm.action_callback(function(window, pane)
      local tab = window:active_tab()
      local panes = tab:panes_with_info()
      local choices = {}
      for i, info in ipairs(panes) do
        table.insert(choices, {
          id = tostring(info.pane:pane_id()),
          label = i .. ": " .. info.pane:get_title(),
        })
      end

      window:perform_action(
        wezterm.action.InputSelector {
          title = "Switch Pane",
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(win, _pane, id)
            if not id then
              return
            end
            for _, info in ipairs(panes) do
              if tostring(info.pane:pane_id()) == id then
                tab:set_zoomed(false)
                info.pane:activate()
                tab:set_zoomed(true)
              end
            end
          end),
        },
        pane
      )
    end),
  })
end
