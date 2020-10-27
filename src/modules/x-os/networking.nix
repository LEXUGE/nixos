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
      netkit.overture = {
        enable = true;
        processors = 2;
        settings = let
          domain-alternative =
            pkgs.writeText "overture-domain-alternative-rule" ".*";
          empty-ip-rules = pkgs.writeText "overture-ip-rules" "";
        in {
          BindAddress = "127.0.0.1:53";
          DebugHTTPAddress = "127.0.0.1:5555";
          PrimaryDNS = [
            {
              Name = "114DNS";
              Address = "114.114.114.114:53";
              Protocol = "udp";
              Timeout = 6;
              SOCKS5Address = "";
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
            {
              Name = "School DNS";
              Address = "10.20.0.233:53";
              Protocol = "udp";
              Timeout = 6;
              SOCKS5Address = "";
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
          ];
          AlternativeDNS = [
            {
              Name = "TLS-CleanBrowsering";
              Address = "whatever.com:853@185.228.168.9";
              Protocol = "tcp-tls";
              Timeout = 6;
              SOCKS5Address = "";
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
            {
              Name = "TLS-Comcast";
              Address = "whatever.com:853@96.113.151.145";
              Protocol = "tcp-tls";
              Timeout = 6;
              SOCKS5Address = "";
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
            {
              Name = "TLS-Google";
              Address = "whatever.com:853@8.8.8.8";
              Protocol = "tcp-tls";
              Timeout = 6;
              SOCKS5Address = "";
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
            {
              Name = "HTTPS-Cloudflare";
              Address = "https://cloudflare-dns.com/dns-query";
              Protocol = "https";
              SOCKS5Address = "";
              Timeout = 6;
              EDNSClientSubnet = {
                Policy = "disable";
                ExternalIP = "";
                NoCookie = true;
              };
            }
          ];
          OnlyPrimaryDNS = false;
          AlternativeDNSConcurrent = true;
          WhenPrimaryDNSAnswerNoneUse = "AlternativeDNS";
          # Empty rule placeholders to cease the complaints.
          IPNetworkFile = {
            "Primary" = "${empty-ip-rules}";
            "Alternative" = "${empty-ip-rules}";
          };
          # Alternative Rules would match everything, while the primary rule set is the domestic domain list. Therefore, domestic query would go via prmiary servers (domestic servers), and anything other than that would match alternative rules and go.
          DomainFile = {
            Primary = "${pkgs.chinalist-overture}/overture-regex-rules.txt";
            Alternative = "${domain-alternative}";
            Matcher = "regex-list";
          };
          HostsFile = { Finder = "full-map"; };
          CacheSize = 4096;
          RejectQType = [ 255 ];
        };
      };
    })

    (mkIf (cfg.iwdConfig != null) {
      environment.etc."iwd/main.conf".text = generators.toINI { } cfg.iwdConfig;
      networking.networkmanager.wifi.backend = "iwd";
    })
  ]);
}
