{ config, pkgs, lib, ... }:

let cfg = config.local.system;
in {
  networking.hostName = cfg.hostname; # Define hostname

  # Allow Spotify Local discovery
  networking.firewall.allowedTCPPorts = [ 57621 ];

  # Enable networkmanager. REMEMBER to add yourself to group in order to use nm related stuff.
  networking.networkmanager.enable = true;

  # Smartdns
  services.smartdns = {
    # Enable smartdns
    enable = true;
    # Settings
    settings = {
      cache-size = 8192;
      server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
      server-https = "https://cloudflare-dns.com/dns-query";
      prefetch-domain = true;
      speed-check-mode = "ping,tcp:80";
    };
  };
  # Use local SmartDNS all the time
  networking.resolvconf.useLocalResolver = true;
}
