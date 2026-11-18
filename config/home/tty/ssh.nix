{
  pkgs,
  hostPlatform,
  config,
  ...
}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh = {
    enable = true;
    package =
      if hostPlatform.isDarwin
      then null
      else pkgs.openssh;

    enableDefaultConfig = false;

    settings = {
      # Home LAN (infra-nixCfg). router, T1, MON1, L2 and M1 have fixed
      # addresses; T2 and T3 are still on dynamic (but long-lived) leases.
      "router" = {
        HostName = "192.168.2.1";
        User = "root";
        IdentityFile = "${sshDir}/github/id_ed25519";
      };
      "T1 T2 T3 MON1" = {
        User = "root";
        IdentityFile = "${sshDir}/agenix/id_ed25519";
      };
      "T1".HostName = "192.168.2.3";
      "T2".HostName = "192.168.2.171";
      "T3".HostName = "192.168.2.106";
      "MON1".HostName = "192.168.2.5";
      # L2's Windows boot (OpenSSH Server).
      "L2" = {
        HostName = "192.168.2.6";
        User = "vanee";
        IdentityFile = "${sshDir}/agenix/id_ed25519";
      };
      # termux-launcher (nix-on-droid fork); its sshd trusts the home-lab key.
      # Non-interactive commands get no PATH: wrap them in `$SHELL -lc`.
      "M1" = {
        HostName = "192.168.2.7";
        User = "nix-on-droid";
        Port = 8022;
        IdentityFile = "${sshDir}/agenix/id_ed25519";
      };
      "M1-adb" = {
        HostName = "127.0.0.1";
        User = "nix-on-droid";
        Port = 18022;
        IdentityFile = "${sshDir}/nix-on-droid/ssh_host_rsa_key";
        HostKeyAlias = "M1-adb";
        CheckHostIP = "no";
      };
      "github.com" = {
        IdentityFile = "${sshDir}/github/id_ed25519";
      };
      "hf.co" = {
        IdentityFile = "${sshDir}/hf/hf";
      };
      "*" = {
        Compression = false;
        AddKeysToAgent = "yes";
        HashKnownHosts = false;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };
    };
  };
}
