{
  pkgs,
  termInputs,
  ...
}: let
  koluPackages = termInputs.kolu.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  services.kolu = {
    enable = true;
    # kolu isn't in nixpkgs — pull the binaries from the flake input. Use termInputs
    # (not inputs) so OS-nixCfg's extraSpecialArgs.inputs doesn't shadow it.
    package = koluPackages.koluBin;
    tuiPackage = koluPackages.kaval-tui;
    padiTuiPackage = koluPackages.padi-tui;
  };
}
