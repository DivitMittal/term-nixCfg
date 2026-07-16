{
  pkgs,
  lib,
  config,
  ...
}: let
  sources = pkgs.callPackage ../../../../pkgs/_sources/generated.nix {};

  # herdr-remote plugin (https://github.com/dcolinmorgan/herdr-remote) is
  # event-driven, not action-driven (its manifest has no [[actions]] block,
  # only an [[events]] handler for pane.agent_status_changed). It's enough to
  # place the source and link it once; no keybind needs to be added.
  herdrRemoteSrc = sources.herdr-remote.src;
  herdrRemoteId = "herdr-remote.relay"; # matches the id field in herdr-plugin.toml

  # herdr-splits (https://github.com/lmilojevicc/herdr-splits.nvim) provides
  # [[actions]] (`nav-left/right/up/down`, `resize-left/right/up/down`) and is
  # also configured via herdr-plugin.toml. We install the source AND wire the
  # herdr-side [[keys.command]] entries below so the keys are intercepted by
  # herdr before they fall through to the foreground app.
  herdrSplitsSrc = sources.herdr-splits.src;
  herdrSplitsId = "herdr-splits"; # matches the id field in herdr-plugin.toml

  # All herdr plugins installed declaratively: each one is placed under
  # herdr's managed plugin directory ($XDG_DATA_HOME/herdr/plugins/github/<id>)
  # and registered via `herdr plugin link` in the activation below.
  herdrPluginIds = [herdrRemoteId herdrSplitsId];

  # Resolves the on-disk path herdr expects for a given plugin id.
  herdrPluginLinkPath = id: "${config.xdg.dataHome}/herdr/plugins/github/${id}";
in {
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    settings = {
      keys.prefix = "ctrl+a";

      # Tab actions: mnemonic letter under the inner-mux prefix.
      keys.new_tab = "prefix+c";
      keys.rename_tab = "prefix+r";
      keys.close_tab = "prefix+d";
      keys.next_tab = "prefix+n";
      keys.previous_tab = "prefix+p";
      keys.switch_tab = "prefix+1..9, prefix+0"; # 0 → tab 10

      # Workspace actions: shift marks the workspace scope.
      keys.new_workspace = "prefix+shift+c";
      keys.rename_workspace = "prefix+shift+r";
      keys.close_workspace = "prefix+shift+d";
      keys.next_workspace = "prefix+shift+n";
      keys.previous_workspace = "prefix+shift+p";
      keys.switch_workspace = "prefix+shift+1..9, prefix+shift+0"; # shift+0 → workspace 10

      # Agents are a herdr-only concept; they occupy the alt+1..9 chord that
      # tmux/zellij/screen use for prefix-free tab jumps. The tab-jump alt layer
      # is intentionally absent here — alt+1..9 is permanently reassigned.
      keys.focus_agent = "alt+1..9";

      # Pane focus uses prefix + arrows so bare Ctrl/Alt arrows remain owned by
      # WezTerm + Neovim smart-splits.
      keys.focus_pane_left = "prefix+left";
      keys.focus_pane_down = "prefix+down";
      keys.focus_pane_up = "prefix+up";
      keys.focus_pane_right = "prefix+right";
      keys.cycle_pane_next = "prefix+tab";
      keys.cycle_pane_previous = "prefix+shift+tab";

      # ── herdr-splits.nvim plugin actions ────────────────────────────────────
      # Bindings use Ctrl+Arrow for nav and Alt+Arrow for resize — the same
      # chord stack WezTerm smartSplits.lua, kitty, and Vim-Cfg
      # smart-splits.nvim already use. The Neovim-side plugin
      # (../Vim-Cfg/lua/plugins/misc.lua) is the primary handler when Neovim
      # has focus inside a herdr pane; these herdr-side entries are the
      # fallback for plain shells, mirroring the same role the prefix+arrows
      # scheme plays in tmux/zellij for shells without a smart-splits
      # companion.
      #
      # Caveat: terminals with their own Ctrl+Arrow bindings (WezTerm
      # smartSplits.lua, kitty) catch the chord before herdr sees it, so
      # these keys.command entries are most useful when running herdr inside
      # a terminal that does NOT own those chords. For WezTerm/kitty panes
      # the prefix+arrow scheme above remains the in-shell navigation path.
      keys.command = [
        {
          key = "ctrl+left";
          type = "plugin_action";
          command = "herdr-splits.nav-left";
          description = "Navigate left across splits (vim/herdr)";
        }
        {
          key = "ctrl+down";
          type = "plugin_action";
          command = "herdr-splits.nav-down";
          description = "Navigate down across splits (vim/herdr)";
        }
        {
          key = "ctrl+up";
          type = "plugin_action";
          command = "herdr-splits.nav-up";
          description = "Navigate up across splits (vim/herdr)";
        }
        {
          key = "ctrl+right";
          type = "plugin_action";
          command = "herdr-splits.nav-right";
          description = "Navigate right across splits (vim/herdr)";
        }
        {
          key = "alt+left";
          type = "plugin_action";
          command = "herdr-splits.resize-left";
          description = "Resize left across splits (vim/herdr)";
        }
        {
          key = "alt+down";
          type = "plugin_action";
          command = "herdr-splits.resize-down";
          description = "Resize down across splits (vim/herdr)";
        }
        {
          key = "alt+up";
          type = "plugin_action";
          command = "herdr-splits.resize-up";
          description = "Resize up across splits (vim/herdr)";
        }
        {
          key = "alt+right";
          type = "plugin_action";
          command = "herdr-splits.resize-right";
          description = "Resize right across splits (vim/herdr)";
        }
      ];

      theme.name = "terminal";
      terminal.shell_mode = "auto";
      ui.show_agent_labels_on_pane_borders = true;
      ui.sound.enabled = true;
      ui.toast.delivery = "system";
    };
  };

  # Install herdr plugins declaratively:
  #   1. Place each plugin source under herdr's managed plugin directory.
  #   2. Run `herdr plugin link` for each id so the server's registry knows
  #      about them. The link is idempotent: if herdr is already running and
  #      a plugin is already registered, the command exits 0 without changes.
  xdg.dataFile = lib.listToAttrs (map
    (id: {
      name = "herdr/plugins/github/${id}";
      value = {
        source =
          if id == herdrRemoteId
          then herdrRemoteSrc
          else if id == herdrSplitsId
          then herdrSplitsSrc
          else throw "unknown herdr plugin id: ${id}";
      };
    })
    herdrPluginIds);

  home.activation.linkHerdrPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Skip silently on systems where herdr isn't on PATH (e.g., nix flake check
    # in a sandbox without /run/current-system).
    command -v herdr >/dev/null 2>&1 || exit 0
    ${lib.concatMapStringsSep "\n" (id: ''
        herdr plugin link '${herdrPluginLinkPath id}' 2>/dev/null || true
      '')
      herdrPluginIds}
  '';
}
