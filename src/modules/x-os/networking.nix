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
    publicKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Public keys of binary caches.";
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
      nix.binaryCaches = lib.mkForce cfg.binaryCaches;
      nix.binaryCachePublicKeys = cfg.publicKeys;

      # Use local DNS server all the time
      networking.resolvconf.useLocalResolver = true;

      # Setup our local DNS
      netkit.dcompass = {
        enable = true;
        package = pkgs.dcompass.dcompass-maxmind;
        settings = {
          ratelimit = 150;
          upstreams = [
            {
              tag = "domestic";
              method = { hybrid = [ "114DNS" "ali" ]; };
            }
            {
              tag = "secure";
              method = {
                hybrid = [ "cloudflare" "quad9" "libredns" "ahadns" ];
              };
            }

            {
              tag = "114DNS";
              method = { udp = { addr = "114.114.114.114:53"; }; };
            }
            {
              tag = "ali";
              method = { udp = { addr = "223.5.5.5:53"; }; };
            }
            {
              tag = "ahadns";
              method = {
                https = {
                  timeout = 4;
                  no_sni = true;
                  name = "doh.la.ahadns.net";
                  addr = "45.67.219.208:443";
                };
              };
            }
            {
              tag = "libredns";
              method = {
                https = {
                  timeout = 4;
                  no_sni = true;
                  name = "doh.libredns.gr";
                  addr = "116.202.176.26:443";
                };
              };
            }
            {
              tag = "cloudflare";
              method = {
                https = {
                  timeout = 4;
                  no_sni = true;
                  name = "cloudflare-dns.com";
                  addr = "1.1.1.1:443";
                };
              };
            }
            {
              tag = "quad9";
              method = {
                https = {
                  timeout = 4;
                  no_sni = true;
                  name = "dns.quad9.net";
                  addr = "9.9.9.9:443";
                };
              };
            }
          ];
          table = [
            {
              tag = "start";
              "if".qtype = [ "AAAA" ];
              "then" = [ "blackhole" "end" ];
              "else" = [ "dispatch" ];
            }
            {
              tag = "dispatch";
              "if".domain = [
                { file = "${pkgs.netkit.chinalist}/google.china.raw.txt"; }
                { file = "${pkgs.netkit.chinalist}/apple.china.raw.txt"; }
                {
                  file =
                    "${pkgs.netkit.chinalist}/accelerated-domains.china.raw.txt";
                }
              ];
              "then" = [ { query = "domestic"; } "end" ];
              "else" = [
                {
                  query = {
                    tag = "secure";
                    cache_policy = "persistent";
                  };
                }
                "end"
              ];
            }
          ];
          address = "0.0.0.0:53";
          cache_size = 4096;
          verbosity = "info";
        };
      };
    })

    (mkIf (cfg.iwdConfig != null) {
      environment.etc."iwd/main.conf".text = generators.toINI { } cfg.iwdConfig;
      networking.networkmanager.wifi.backend = "iwd";
    })
  ]);
}
