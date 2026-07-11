{
  pkgs,
  lib,
  config,
  ...
}: let
  sources = pkgs.callPackage ../../../pkgs/_sources/generated.nix {};

  # herdr-remote plugin (https://github.com/dcolinmorgan/herdr-remote) is
  # event-driven, not action-driven (its manifest has no [[actions]] block,
  # only an [[events]] handler for pane.agent_status_changed). It's enough to
  # place the source and link it once; no keybind needs to be added.
  herdrRemoteSrc = sources.herdr-remote.src;
  herdrRemoteId = "herdr-remote.relay"; # matches the id field in herdr-plugin.toml

  # herdr's managed plugin directory is $XDG_DATA_HOME/herdr/plugins/github/<id>.
  # The plugin must be linked into herdr's registry via `herdr plugin link` for
  # the server to discover it; the activation hook below does that idempotently.
  herdrRemoteLinkPath = "${config.xdg.dataHome}/herdr/plugins/github/${herdrRemoteId}";
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

      theme.name = "terminal";
      terminal.shell_mode = "auto";
      ui.show_agent_labels_on_pane_borders = true;
      ui.sound.enabled = true;
      ui.toast.delivery = "system";
    };
  };

  # Install herdr-remote declaratively:
  #   1. Place the plugin source under herdr's managed plugin directory.
  #   2. Run `herdr plugin link` so the server's registry knows about it.
  # The link is idempotent: if herdr is already running and the plugin is
  # already registered, the command exits 0 without changes.
  xdg.dataFile."herdr/plugins/github/${herdrRemoteId}".source = herdrRemoteSrc;

  home.activation.linkHerdrRemote = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Skip silently on systems where herdr isn't on PATH (e.g., nix flake check
    # in a sandbox without /run/current-system).
    command -v herdr >/dev/null 2>&1 || exit 0
    herdr plugin link '${herdrRemoteLinkPath}' 2>/dev/null || true
  '';
}
