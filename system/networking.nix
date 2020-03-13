{ config, pkgs, ... }:

{
  networking.hostName = config.lib.system.hostname; # Define hostname.

  # Allow Spotify Local discovery
  networking.firewall.allowedTCPPorts = [ 57621 ];

  services.smartdns = {
    enable = true;
    settings = {
      cache-size = 8192;
      server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
      server-https = "https://cloudflare-dns.com/dns-query";
      prefetch-domain = true;
      speed-check-mode = "ping,tcp:80";
    };
  };
}
