{
  config,
  pkgs,
  base16Scheme,
  ...
}: let
  sources = pkgs.callPackage ../../../pkgs/_sources/generated.nix {};

  # Render a zellij theme from the same base16 palette that powers
  # wezterm/colors/cyberpunk.toml (home/wezterm.nix) and OS-nixCfg.
  # Zellij's theme parser only accepts RGB triplets or `#RGB`/`#RRGGBB` —
  # no alpha channel — so "transparency" here is achieved by routing
  # every chrome background to `base00` (pitch black), which matches
  # WezTerm's terminal background. Combined with wezterm's
  # `window_background_opacity = 0.85`, the entire window composites
  # over the wallpaper at the same alpha and reads as one surface.
  # Decode a 2-char hex pair into a decimal integer. `builtins.fromJSON`
  # only accepts decimal JSON numbers — it rejects `0x...` — so this
  # small lookup is needed.
  parseHex = h: let
    digit = c:
      if c >= "0" && c <= "9"
      then builtins.fromJSON c
      else if c == "a"
      then 10
      else if c == "b"
      then 11
      else if c == "c"
      then 12
      else if c == "d"
      then 13
      else if c == "e"
      then 14
      else if c == "f"
      then 15
      else throw "invalid hex digit: ${c}";
    hi = digit (builtins.substring 0 1 h);
    lo = digit (builtins.substring 1 1 h);
  in
    hi * 16 + lo;
  rgb = name: let
    h = base16Scheme.${name};
  in [
    (parseHex (builtins.substring 0 2 h))
    (parseHex (builtins.substring 2 2 h))
    (parseHex (builtins.substring 4 2 h))
  ];
in {
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;

    enableFishIntegration = false;
    enableZshIntegration = false;
    enableBashIntegration = false;

    settings = {
      show_startup_tips = false;
      default_layout = "vertical-tabs-right";
      theme = "cyberpunk";

      themes.cyberpunk = {
        text_unselected = {
          base = rgb "base05";
          background = rgb "base00";
          emphasis_0 = rgb "base08"; # red    — errors
          emphasis_1 = rgb "base0C"; # cyan   — quotes
          emphasis_2 = rgb "base0B"; # green  — strings
          emphasis_3 = rgb "base0E"; # magenta — italic
        };
        text_selected = {
          base = rgb "base05";
          background = rgb "base02"; # selection surface
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        ribbon_selected = {
          base = rgb "base00";
          background = rgb "base0C"; # active tab accent (cyan)
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0E";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0D";
        };
        ribbon_unselected = {
          base = rgb "base03";
          background = rgb "base00";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base05";
          emphasis_2 = rgb "base0D";
          emphasis_3 = rgb "base0E";
        };
        table_title = {
          base = rgb "base0C";
          background = rgb "base00";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        table_cell_selected = {
          base = rgb "base05";
          background = rgb "base02";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        table_cell_unselected = {
          base = rgb "base05";
          background = rgb "base00";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        list_selected = {
          base = rgb "base05";
          background = rgb "base02";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        list_unselected = {
          base = rgb "base05";
          background = rgb "base00";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0B";
          emphasis_3 = rgb "base0E";
        };
        frame_selected = {
          base = rgb "base0C";
          background = rgb "base00";
          emphasis_0 = rgb "base08";
          emphasis_1 = rgb "base0C";
          emphasis_2 = rgb "base0E";
          emphasis_3 = 0;
        };
        frame_highlight = {
          base = rgb "base0E";
          background = rgb "base00";
          emphasis_0 = rgb "base0E";
          emphasis_1 = rgb "base0E";
          emphasis_2 = rgb "base0E";
          emphasis_3 = rgb "base0E";
        };
        exit_code_success = {
          base = rgb "base0B";
          background = rgb "base00";
          emphasis_0 = rgb "base0C";
          emphasis_1 = rgb "base00";
          emphasis_2 = rgb "base0E";
          emphasis_3 = rgb "base0D";
        };
        exit_code_error = {
          base = rgb "base08";
          background = rgb "base00";
          emphasis_0 = rgb "base0A";
          emphasis_1 = 0;
          emphasis_2 = 0;
          emphasis_3 = 0;
        };
        multiplayer_user_colors = {
          player_1 = rgb "base0C";
          player_2 = rgb "base0D";
          player_3 = rgb "base0B";
          player_4 = rgb "base0F";
          player_5 = rgb "base08";
          player_6 = 0;
          player_7 = rgb "base0A";
          player_8 = 0;
          player_9 = 0;
          player_10 = 0;
        };
      };

      plugins = {
        harpoon._props.location = "file:${config.xdg.configHome}/zellij/plugins/harpoon.wasm";
        vertical-tabs._props.location = "file:${config.xdg.configHome}/zellij/plugins/vertical-tabs.wasm";
      };

      # Leader for tmux-style keybinds (keybinds.tmux below).
      # Override the zellij default (Ctrl b) since terminal emulators and
      # readline also claim Ctrl a for "go to start of line".
      keybinds.leader = "Ctrl a";

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

      keybinds.tmux._children = [
        {
          bind = {
            _args = ["v"];
            _children = [
              {NewPane = "Right";}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["-"];
            _children = [
              {NewPane = "Down";}
              {SwitchToMode = "Normal";}
            ];
          };
        }
      ];
    };

    layouts.vertical-tabs-right = {
      layout._children = [
        {
          pane = {
            split_direction = "vertical";
            _children = [
              {pane = {};}
              {
                pane = {
                  size = 18;
                  borderless = true;
                  plugin.location = "vertical-tabs";
                };
              }
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
