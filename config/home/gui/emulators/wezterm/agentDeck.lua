return function(wezterm, config)
  local agent_deck = wezterm.plugin.require "https://github.com/Eric162/wezterm-agent-deck"

  -- tab_title/right_status are disabled here because both agent-deck and
  -- tabline.wez (tabline.lua) register their own format-tab-title and
  -- update-status handlers, and WezTerm keeps only the LAST-registered
  -- handler's output for each — tabline.lua loads after this module, so it
  -- would silently clobber agent-deck's rendering every cycle. Detection
  -- and notifications still run (agent-deck always registers an
  -- update-status handler that polls panes, regardless of these flags);
  -- tabline.lua reads agent_deck.get_agent_state()/get_status_icon() as a
  -- custom component instead of letting agent-deck render itself.
  --
  -- If wezterm-agent-cards is vendored AND its own Claude Code plugin is
  -- enabled (in whichever repo owns ~/.claude/settings.json — not this
  -- one), its sidebar becomes the primary "does an agent need me" surface:
  -- poll faster for its benefit, and drop agent-deck's own OS notifications
  -- so the sidebar's waiting-state cue isn't duplicated. This is a cheap
  -- file-existence check, not a real load — agentCards.lua does the actual
  -- dofile and skips quietly if it's not there yet.
  local agent_cards_present = (function()
    local f = io.open(os.getenv "HOME" .. "/.claude/plugins/wezterm-agent-cards/wezterm/init.lua", "r")
    if f then
      f:close()
      return true
    end
    return false
  end)()

  agent_deck.apply_to_config(config, {
    icons = { style = "nerd" },
    tab_title = { enabled = false },
    right_status = { enabled = false },
    update_interval = agent_cards_present and 500 or nil,
    notifications = agent_cards_present and { enabled = false } or nil,
  })
end
