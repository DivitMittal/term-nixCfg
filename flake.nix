{
  description = "term-nixCfg's flake";

  outputs = inputs: let
    inherit (inputs.flake-parts.lib) mkFlake;
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
          then import inputs."nixpkgs-2605" {inherit system;}
          else import inputs.nixpkgs {inherit system;};
      };
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    "nixpkgs-2605".url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-2605";
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
