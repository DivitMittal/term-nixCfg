return function(wezterm, config)
  local tabline = wezterm.plugin.require "https://github.com/michaelbrusegard/tabline.wez"
  local agent_deck = wezterm.plugin.require "https://github.com/Eric162/wezterm-agent-deck"
  local stack = wezterm.plugin.require "https://github.com/bad-noodles/stack.wez"

  -- agentDeck.lua disables agent-deck's own tab_title/right_status
  -- rendering (it loses a handler-registration race against this plugin),
  -- so its detected status is surfaced here instead, as plain tabline
  -- components. tabline.wez's function-component slots only support plain
  -- Text output (no per-status Foreground), so this loses agent-deck's
  -- color coding — the icon shape (nerd style: working/waiting/idle/
  -- inactive) is what distinguishes state here.
  local function pane_status(pane_id)
    local state = agent_deck.get_agent_state(pane_id)
    return state and state.status or nil
  end

  -- Checks every pane in the tab, not just the active one — a background
  -- pane in a split (e.g. Claude running behind an editor pane) still
  -- needs to surface here. Mirrors agent-deck's own multi-pane example in
  -- its README. Highest-priority status across the tab's panes wins.
  local status_priority = { waiting = 3, working = 2, idle = 1 }

  local function agent_tab_icon(tab)
    local best = nil
    for _, pane_info in ipairs(tab.panes or {}) do
      local status = pane_status(pane_info.pane_id)
      if status and (not best or (status_priority[status] or 0) > (status_priority[best] or 0)) then
        best = status
      end
    end
    if not best then
      return ""
    end
    return agent_deck.get_status_icon(best) .. " "
  end

  local function agent_status_summary(window)
    local counts = { waiting = 0, working = 0 }
    local ok = pcall(function()
      for _, mux_tab in ipairs(window:mux_window():tabs()) do
        for _, p in ipairs(mux_tab:panes()) do
          local status = pane_status(p:pane_id())
          if status == "waiting" or status == "working" then
            counts[status] = counts[status] + 1
          end
        end
      end
    end)
    if not ok then
      return ""
    end

    if counts.waiting > 0 then
      return agent_deck.get_status_icon "waiting" .. counts.waiting
    end
    if counts.working > 0 then
      return agent_deck.get_status_icon "working" .. counts.working
    end
    return ""
  end

  -- stackWez.lua disables stack.wez's own enrich_tab_title (same
  -- format-tab-title race as agent-deck); stack_info() is a stateless
  -- public function, safe to call directly here.
  local function stack_tab_indicator(tab)
    local info = stack.stack_info(tab.tab_id)
    if not info then
      return ""
    end
    return " [" .. info.index .. "/" .. info.count .. "]"
  end

  tabline.setup {
    options = {
      theme = "Dracula",
    },
    sections = {
      tabline_a = { "mode" },
      tabline_b = { "workspace" },
      -- Defaults from tabline.wez's config.lua, with the agent-deck icon
      -- prepended and the stack.wez position suffixed.
      tab_active = {
        agent_tab_icon,
        "index",
        { "parent", padding = 0 },
        "/",
        { "cwd", padding = { left = 0, right = 1 } },
        { "zoomed", padding = 0 },
        stack_tab_indicator,
      },
      tab_inactive = {
        agent_tab_icon,
        "index",
        { "process", padding = { left = 0, right = 1 } },
        stack_tab_indicator,
      },
      tabline_x = { agent_status_summary },
      tabline_y = { "hostname" },
      tabline_z = { "domain" },
    },
    -- smart_ssh.wezterm has first-class tabline.wez support: while its
    -- fuzzy host picker is open, tabline_a temporarily shows " SSH "
    -- instead of the mode indicator, reverting automatically on
    -- selection/cancel. This is tabline's own extension mechanism
    -- (temporary sections override, scoped to show/hide events) — not the
    -- ad-hoc composition used for agent-deck/stack.wez above, since this
    -- one doesn't touch format-tab-title/update-status at all.
    extensions = {
      {
        "smart_ssh",
        events = {
          show = "smart_ssh.fuzzy_selector.opened",
          hide = {
            "smart_ssh.fuzzy_selector.canceled",
            "smart_ssh.fuzzy_selector.selected",
          },
        },
        sections = {
          tabline_a = { " SSH " },
        },
      },
    },
  }

  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = true

  tabline.apply_to_config(config)
end
