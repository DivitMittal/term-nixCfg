{
  config,
  pkgs,
  ...
}: let
  harpoonPlugin = pkgs.fetchurl {
    pname = "zellij-harpoon";
    version = "0.3.0";
    url = "https://github.com/Nacho114/harpoon/releases/download/v0.3.0/harpoon.wasm";
    hash = "sha256-5CqgYx4FzNr2f4NvV2qQ89vEeBKd6iG/NrRLa6O1CmY=";
  };

  verticalTabsPlugin = pkgs.fetchurl {
    pname = "zellij-vertical-tabs";
    version = "0.1.0";
    url = "https://github.com/cfal/zellij-vertical-tabs/releases/download/v0.1.0/zellij-vertical-tabs.wasm";
    hash = "sha256-BJljSyS1JMsdfDsbx2wUj2IXCPQnk51LNaF6Sc7U0xw=";
  };
in {
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;

    enableFishIntegration = false;
    enableZshIntegration = false;
    enableBashIntegration = false;

    settings = {
      default_layout = "vertical-tabs-left";

      plugins = {
        harpoon._props.location = "file:${config.xdg.configHome}/zellij/plugins/harpoon.wasm";
        vertical-tabs._props.location = "file:${config.xdg.configHome}/zellij/plugins/vertical-tabs.wasm";
      };

      keybinds.shared_except = {
        _args = ["locked"];
        _children = [
          {
            bind = {
              _args = ["Ctrl y"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["harpoon"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
              ];
            };
          }
        ];
      };
    };

    layouts.vertical-tabs-left = {
      layout._children = [
        {
          pane = {
            split_direction = "vertical";
            _children = [
              {
                pane = {
                  size = 18;
                  borderless = true;
                  plugin.location = "vertical-tabs";
                };
              }
              {pane = {};}
            ];
          };
        }
        {
          pane = {
            size = 1;
            borderless = true;
            plugin.location = "zellij:status-bar";
          };
        }
      ];
    };
  };

  # Keep plugin paths stable for zellij's permission prompts.
  xdg.configFile = {
    "zellij/plugins/harpoon.wasm".source = harpoonPlugin;
    "zellij/plugins/vertical-tabs.wasm".source = verticalTabsPlugin;
  };
}
