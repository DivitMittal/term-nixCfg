return function(wezterm, config)
  local smart_ssh = wezterm.plugin.require "https://github.com/DavidRR-F/smart_ssh.wezterm"

  config.keys = config.keys or {}

  -- LEADER+s is already a plain (non-ssh) split in binds.lua; the
  -- shift-cased variant here is the ssh-picker equivalent.
  table.insert(config.keys, { mods = "LEADER", key = "S", action = smart_ssh.tab() })

  -- apply_to_config sets config.ssh_domains from wezterm.enumerate_ssh_hosts()
  -- (reading ~/.ssh/config) — Config::ssh_domains() REPLACES (not merges)
  -- WezTerm's built-in default ssh_domains auto-discovery, so this must
  -- stay the only place config.ssh_domains is set. Called last per
  -- upstream's note to call apply_to_config after keys are set.
  smart_ssh.apply_to_config(config)
end
