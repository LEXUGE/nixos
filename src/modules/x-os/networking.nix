{ config, pkgs, lib, ... }:

with lib;

let cfg = config.x-os;
in {
  options.x-os = {
    hostname = mkOption {
      type = types.str;
      description = "The hostname of the system";
    };
    binaryCaches = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Binary caches to use.";
    };
    iwdConfig = mkOption {
      type = with types; nullOr (attrsOf (attrsOf (oneOf [ bool int str ])));
      default = null;
      description = "Configuratoin of iNet Wireless Daemon.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    ({
      networking.hostName = cfg.hostname; # Define hostname

      networking.networkmanager = {
        # Enable networkmanager. REMEMBER to add yourself to group in order to use nm related stuff.
        enable = true;
        # Don't use DNS advertised by connected network. Use local configuration
        dns = "none";
      };

      # Customized binary caches list (with fallback to official binary cache)
      nix.binaryCaches = cfg.binaryCaches;

      # Use local DNS server all the time
      networking.resolvconf.useLocalResolver = true;

      # Setup our local DNS
      netkit.smartdns = {
        enable = true;
        china-list = true;
        settings = {
          bind = "[::]:53";
          log-level = "debug";
          cache-size = 4096;
          server-https = [
            "https://cloudflare-dns.com/dns-query"
            "https://dns.google/dns-query"
            "https://1.1.1.1/dns-query"
            "https://1.0.0.1/dns-query"
            "https://9.9.9.9/dns-query"
            "https://dnsforge.de/dns-query"
            "https://dns.dnshome.de/dns-query"
            "https://ordns.he.net/dns-query" # HE
          ];
          server-tls = [
            "8.8.8.8:853"
            "1.1.1.1:853"
            "9.9.9.9:853"
            "96.113.151.145:853" # Comcast
            "185.228.168.9:853" # CleanBrowsering
          ];
          server = [
            "114.114.114.114 -group china -exclude-default-group"
            "10.20.0.233 -group china -exclude-default-group"
            "223.5.5.5 -group china -exclude-default-group"
          ]; # Server for China-list
          prefetch-domain = true;
          speed-check-mode = "ping,tcp:80";
        };
      };
    })

    (mkIf (cfg.iwdConfig != null) {
      environment.etc."iwd/main.conf".text = generators.toINI { } cfg.iwdConfig;
      networking.networkmanager.wifi.backend = "iwd";
    })
  ]);
}
