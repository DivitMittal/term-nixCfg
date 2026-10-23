{
  pkgs,
  termInputs,
  ...
}: let
  inherit (pkgs.stdenvNoCC) hostPlatform;
in {
  services.kolu = {
    # kolu publishes nothing for x86_64-darwin (its agent-distro doesn't build
    # on Intel Macs), and it isn't on nixpkgs, npm or Homebrew either.
    enable = !(hostPlatform.isDarwin && hostPlatform.isx86_64);
    # kolu isn't in nixpkgs — pull the binary from the flake input. Use termInputs
    # (not inputs) so OS-nixCfg's extraSpecialArgs.inputs doesn't shadow it.
    package = termInputs.kolu.packages.${hostPlatform.system}.koluBin;
  };
}
