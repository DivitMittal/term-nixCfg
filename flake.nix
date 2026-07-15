{
  description = "term-nixCfg's flake";

  outputs = inputs: let
    inherit (inputs.flake-parts.lib) mkFlake;
    # Nixpkgs 26.11 dropped x86_64-darwin only (aarch64-darwin is still
    # supported on unstable). Pin x86_64-darwin to the 26.05-darwin branch
    # (security-supported through end of 2026) and keep everything else on
    # unstable. The flake-modules (devshell/treefmt/git-hooks/actions-nix)
    # import `nixpkgs` from their own input, so their `follows` below also
    # point at `nixpkgs-stable` — they always use stable regardless of
    # system; user-side perSystem modules get the conditional pkgs via
    # `_module.args.pkgs`.
    isX86Darwin = system: system == "x86_64-darwin";
  in
    mkFlake {inherit inputs;} ({inputs, ...}: {
      systems = import inputs.systems;
      imports = [
        (inputs.import-tree ./flake)
        ./config
      ];
      perSystem = {system, ...}: {
        _module.args.pkgs =
          if isX86Darwin system
          then import inputs."nixpkgs-stable" {inherit system;}
          else import inputs.nixpkgs {inherit system;};
      };
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Nixpkgs 26.11 dropped x86_64-darwin. Per-system `_module.args.pkgs`
    # above picks this branch on darwin. Flake-modules (devshell/
    # treefmt/git-hooks/actions-nix) import `nixpkgs` from their own
    # input, so their `follows` below also point here so they evaluate
    # successfully on darwin (they use stable everywhere — those are
    # toolchain packages that don't differ much between stable/unstable).
    "nixpkgs-stable".url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };
    import-tree.url = "github:vic/import-tree";
    # tmux-fzf (sainnhe/tmux-fzf) is now vendored through pkgs/nvfetcher.toml
    # instead of a flake input — see pkgs/_sources/generated.nix and
    # config/home/multiplexers/tmux.nix (`sources.tmux-fzf.src`).
    # Kolu terminal multiplexer — supplies the services.kolu HM module + package
    # (see config/home/multiplexers/kolu.nix).
    kolu.url = "github:juspay/kolu";
  };
}
