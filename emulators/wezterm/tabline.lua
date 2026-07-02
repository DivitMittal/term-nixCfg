return function(wezterm, config)
  local function basename(path)
    return path:gsub("[/\\]+$", ""):match "([^/\\]+)$" or path
  end

  local function current_dir(pane)
    local cwd = pane.current_working_dir

    if cwd and cwd.file_path then
      return basename(cwd.file_path)
    end

    if cwd then
      local uri = wezterm.url.parse(tostring(cwd))
      if uri and uri.file_path then
        return basename(uri.file_path)
      end
    end

    return "~"
  end

  wezterm.on("format-tab-title", function(tab)
    local pane = tab.active_pane
    local process = basename(pane.foreground_process_name or "")
    local text = process .. " - " .. current_dir(pane)

    return {
      { Text = " " .. text .. " " },
    }
  end)

  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = true
end
