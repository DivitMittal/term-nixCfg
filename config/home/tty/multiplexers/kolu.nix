{
  lib,
  pkgs,
  termInputs,
  ...
}: let
  koluPkgs = termInputs.kolu.packages.${pkgs.stdenvNoCC.hostPlatform.system} or null;
in {
  # Upstream kolu doesn't publish every system (no x86_64-darwin); its HM module
  # indexes self.packages.${system} unconditionally, so only enable where it exists.
  services.kolu = lib.mkIf (koluPkgs != null) {
    enable = true;
    # kolu isn't in nixpkgs — pull the binary from the flake input. Use termInputs
    # (not inputs) so OS-nixCfg's extraSpecialArgs.inputs doesn't shadow it.
    package = koluPkgs.koluBin;
  };
}
