{ config, pkgs, ... }:

{
  networking.hostName = "nixos"; # Define your hostname.

  # Allow Spotify Local discovery
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
