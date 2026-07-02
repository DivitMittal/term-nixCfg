{
  config,
  pkgs,
  ...
}: let
  sources = pkgs.callPackage ../../../pkgs/_sources/generated.nix {};
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
    "zellij/plugins/harpoon.wasm".source = sources.zellij-harpoon.src;
    "zellij/plugins/vertical-tabs.wasm".source = sources.zellij-vertical-tabs.src;
  };
}
