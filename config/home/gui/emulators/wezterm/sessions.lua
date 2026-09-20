return function(wezterm, config)
  local sessions = wezterm.plugin.require "https://github.com/abidibo/wezterm-sessions"

  -- Save state under XDG data home rather than the plugin's git-clone cache
  -- dir, so saved sessions survive `wezterm.plugin.update_all()`.
  sessions.apply_to_config(config, {
    auto_save_interval_s = 30,
    git_branch_warn = true,
    save_state_dir = "default-user-owned",
  })
end
