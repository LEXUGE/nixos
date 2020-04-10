{ config, pkgs, lib, ... }:

let cfg = config.local.system;
in {
  networking.hostName = cfg.hostname; # Define hostname

  # Allow Spotify Local discovery
  networking.firewall.allowedTCPPorts = [ 57621 ];

  networking.networkmanager = {
    # Enable networkmanager. REMEMBER to add yourself to group in order to use nm related stuff.
    enable = true;
    # Don't use DNS advertised by connected network. Use local configuration
    dns = "none";
  };

  # Use local DNS server provided by clash all the time
  networking.resolvconf.useLocalResolver = true;
}
