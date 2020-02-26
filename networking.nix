{ config, pkgs, ... }:

{
  imports = [ ./modules/smartdns.nix ];
  networking.hostName = "nixos"; # Define your hostname.

  # Allow Spotify Local discovery
  networking.firewall.allowedTCPPorts = [ 57621 ];

  services.smartdns = {
    enable = true;
    cacheSize = 8192;
    # Use cloudflare and Google DNS over either TLS or HTTPS to avoid DNS poison
    servers.tls = [ "8.8.8.8:853" " 1.1.1.1:853" ];
    servers.https = [ "https://cloudflare-dns.com/dns-query" ];
    extraConfig = ''
      prefetch-domain yes
      speed-check-mode ping,tcp:80
    '';
  };
}
