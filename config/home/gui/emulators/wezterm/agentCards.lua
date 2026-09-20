return function(wezterm, config)
  local agent_deck = wezterm.plugin.require "https://github.com/Eric162/wezterm-agent-deck"

  -- Vendored via home.file in wezterm.nix (not a wezterm.plugin.require
  -- package — it's also a Claude Code plugin, installed by convention
  -- under ~/.claude/plugins/). Skip quietly if it's not there yet, or if
  -- WezTerm's Lua sandbox can't dofile it for any reason — this must never
  -- break the rest of the config.
  local plugin_root = os.getenv "HOME" .. "/.claude/plugins/wezterm-agent-cards"
  local ok, agent_cards = pcall(dofile, plugin_root .. "/wezterm/init.lua")
  if not ok then
    return
  end

  -- hide_tab_bar = false keeps WezTerm's native tab bar (tabline.lua)
  -- alongside the sidebar pane agent-cards spawns per-tab, instead of
  -- letting apply_to_config's default (config.enable_tab_bar = false)
  -- replace it.
  config.keys = config.keys or {}
  local before_count = #config.keys

  agent_cards.apply_to_config(config, {
    agent_deck = agent_deck,
    sidebar_cols = 26,
    hide_tab_bar = false,
  })

  -- apply_to_config unconditionally appends its own keybindings with no
  -- option to omit individual ones. Strip the two sets that collide with
  -- bindings this config already owns — only among the entries it just
  -- added (by index), so pre-existing bindings from other modules are
  -- never touched even if they happen to share a mods/key pair:
  --  - ALT+1..9: herdr.nix's keys.focus_agent deliberately claims this
  --    exact chord for its own inner-mux agent switching. ANY WezTerm-level
  --    binding for a chord intercepts the keypress before it reaches the
  --    pty, regardless of which entry wins — so these must be removed
  --    outright, not just shadowed by a later binding.
  --  - CTRL+SHIFT+d/e: sessions.lua's delete/edit-session bindings.
  local blocked = { ["CTRL|SHIFT:d"] = true, ["CTRL|SHIFT:e"] = true }
  for i = 1, 9 do
    blocked["ALT:" .. i] = true
  end

  local kept = {}
  for i, k in ipairs(config.keys) do
    local id = (k.mods or "") .. ":" .. (k.key or "")
    if not (i > before_count and blocked[id]) then
      table.insert(kept, k)
    end
  end
  config.keys = kept
end
