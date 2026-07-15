{
  config,
  pkgs,
  base16Scheme,
  ...
}: let
  sources = pkgs.callPackage ../../../../pkgs/_sources/generated.nix {};

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

      # Leader for tmux-style keybinds (keybinds.tmux below). Zellij 0.44
      # models this as a normal binding into tmux mode, not a `leader` node.

      keybinds.normal._children = [
        {
          unbind._args = [
            "Alt Left"
            "Alt Right"
            "Alt Up"
            "Alt Down"
            "Alt h"
            "Alt l"
            "Alt j"
            "Alt k"
          ];
        }
      ];

      keybinds.shared_except = {
        _args = ["locked"];
        _children = [
          {
            bind = {
              _args = ["Ctrl a"];
              _children = [{SwitchToMode = "Tmux";}];
            };
          }
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

          # ── alt+ navigation layer (prefix-free) ──
          # Mirrors the Ctrl-a + mnemonic scheme but fires without entering a
          # mode, so tab/session switching is one chord. Bare Alt+Arrow is
          # owned by WezTerm + smart-splits.nvim (resize), so letters are used.
          # Lowercase = tabs, uppercase = sessions (see alt+ session layer
          # below for the workspace → session-manager mapping).
          {
            bind = {
              _args = ["Alt c"];
              _children = [{NewTab = {};} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt r"];
              _children = [{SwitchToMode = "RenameTab";} {TabNameInput = 0;}];
            };
          }
          {
            bind = {
              _args = ["Alt d"];
              _children = [{CloseTab = {};} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt n"];
              _children = [{GoToNextTab = {};} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt p"];
              _children = [{GoToPreviousTab = {};} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 1"];
              _children = [{GoToTab = 1;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 2"];
              _children = [{GoToTab = 2;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 3"];
              _children = [{GoToTab = 3;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 4"];
              _children = [{GoToTab = 4;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 5"];
              _children = [{GoToTab = 5;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 6"];
              _children = [{GoToTab = 6;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 7"];
              _children = [{GoToTab = 7;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 8"];
              _children = [{GoToTab = 8;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 9"];
              _children = [{GoToTab = 9;} {SwitchToMode = "Normal";}];
            };
          }
          {
            bind = {
              _args = ["Alt 0"];
              _children = [{GoToTab = 10;} {SwitchToMode = "Normal";}];
            };
          }
          # ── alt+ session layer (prefix-free) ──
          # Zellij 0.44 dropped the "workspace" concept (was a tmux-style
          # second layer above tabs). Sessions are now top-level — they're
          # managed by the built-in `zellij:session-manager` plugin, which
          # exposes create / rename / delete / switch in one floating UI.
          # So each Alt+uppercase binding opens that plugin; the action
          # inside the UI is chosen interactively, not from the binding.
          {
            bind = {
              _args = ["Alt C"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["session-manager"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
                {SwitchToMode = "Normal";}
              ];
            };
          }
          {
            bind = {
              _args = ["Alt R"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["session-manager"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
                {SwitchToMode = "Normal";}
              ];
            };
          }
          {
            bind = {
              _args = ["Alt D"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["session-manager"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
                {SwitchToMode = "Normal";}
              ];
            };
          }
          {
            bind = {
              _args = ["Alt N"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["session-manager"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
                {SwitchToMode = "Normal";}
              ];
            };
          }
          {
            bind = {
              _args = ["Alt P"];
              _children = [
                {
                  LaunchOrFocusPlugin = {
                    _args = ["session-manager"];
                    floating = true;
                    move_to_focused_tab = true;
                  };
                }
                {SwitchToMode = "Normal";}
              ];
            };
          }
        ];
      };

      keybinds.tmux._children = [
        {
          unbind._args = [
            "h"
            "j"
            "k"
            "l"
          ];
        }
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
        {
          bind = {
            _args = ["c"];
            _children = [
              {NewTab = {};}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["r"];
            _children = [
              {SwitchToMode = "RenameTab";}
              {TabNameInput = 0;}
            ];
          };
        }
        {
          bind = {
            _args = ["d"];
            _children = [
              {CloseTab = {};}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["n"];
            _children = [
              {GoToNextTab = {};}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["p"];
            _children = [
              {GoToPreviousTab = {};}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["1"];
            _children = [
              {GoToTab = 1;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["2"];
            _children = [
              {GoToTab = 2;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["3"];
            _children = [
              {GoToTab = 3;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["4"];
            _children = [
              {GoToTab = 4;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["5"];
            _children = [
              {GoToTab = 5;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["6"];
            _children = [
              {GoToTab = 6;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["7"];
            _children = [
              {GoToTab = 7;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["8"];
            _children = [
              {GoToTab = 8;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["9"];
            _children = [
              {GoToTab = 9;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["0"];
            _children = [
              {GoToTab = 10;}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["Left"];
            _children = [
              {MoveFocus = "Left";}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["Down"];
            _children = [
              {MoveFocus = "Down";}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["Up"];
            _children = [
              {MoveFocus = "Up";}
              {SwitchToMode = "Normal";}
            ];
          };
        }
        {
          bind = {
            _args = ["Right"];
            _children = [
              {MoveFocus = "Right";}
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
