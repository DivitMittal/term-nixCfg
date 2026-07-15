return function(wezterm, config)
  local tabline = wezterm.plugin.require "https://github.com/michaelbrusegard/tabline.wez"

  tabline.setup {
    options = {
      theme = "Dracula",
    },
    sections = {
      tabline_a = { "mode" },
      tabline_b = { "workspace" },
      tabline_x = {},
      tabline_y = { "hostname" },
      tabline_z = { "domain" },
    },
  }

  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = true

  tabline.apply_to_config(config)
end
