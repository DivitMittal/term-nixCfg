{
  inputs,
  lib,
  ...
}: let
  customLib = {
    mkUvxBin = pkgs: name: args:
      pkgs.writeShellScriptBin name ''
        exec ${pkgs.uv}/bin/uv tool run ${args} "$@"
      '';
  };
in {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devshells.default = {
      devshell = rec {
        name = "term-nixCfg";
        motd = "{202}Welcome to {91}${name} {202}devshell!{reset} \n $(menu)";
        startup = {
          git-hooks.text = ''
            ${config.pre-commit.installationScript}
          '';
        };
        packages = lib.attrsets.attrValues {
          inherit
            (pkgs)
            ### LSPs & Formatters
            ## Nix
            nixd
            alejandra
            ## Package management
            nvfetcher
            ## Lua
            stylua
            ;
          ## AI context
          apm = customLib.mkUvxBin pkgs "apm" "--from apm-cli apm";
        };
      };
      commands = [
        {
          name = "pkgs-update";
          help = "Update package sources via nvfetcher";
          command = "nvfetcher -c $PRJ_ROOT/pkgs/nvfetcher.toml -o $PRJ_ROOT/pkgs/_sources";
        }
      ];
    };
  };
}
