{
  pkgs,
  termInputs,
  ...
}: {
  services.kolu = {
    enable = true;
    # kolu isn't in nixpkgs — pull the binary from the flake input. Use termInputs
    # (not inputs) so OS-nixCfg's extraSpecialArgs.inputs doesn't shadow it.
    package = termInputs.kolu.packages.${pkgs.stdenvNoCC.hostPlatform.system}.koluBin;
  };
}
