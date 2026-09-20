-- Tags windows opened in the "quake" workspace (`wezterm start --domain
-- local-mux --attach --workspace quake`) with a stable OS window title.
-- macOS has no X11/Wayland-style window class to match on, so the
-- Hammerspoon toggle (hammerspoon-nix repo, myCfg/WindowManager/quakeTerm.lua)
-- and Sway's app_id-based scratchpad rule (infra-nixCfg repo,
-- home/gui/linux/sway/quakeTerm.nix) both rely on `--class wezterm-quake`
-- for identification on Linux, while this title is what macOS matches on.
return function(wezterm, config)
  wezterm.on("format-window-title", function(tab, pane, tabs, panes, cfg)
    if wezterm.mux.get_active_workspace() == "quake" then
      return "wezterm-quake"
    end
  end)
end
