{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.x-os;
  zonefile = pkgs.writeText "a.cn.zone" ''
    ; replace the trust-dns.org with your own name
    @   IN          SOA     trust-dns.org. root.trust-dns.org. (
                                    2021031306       ; Serial
                                    28800   ; Refresh
                                    7200    ; Retry
                                    604800  ; Expire
                                    86400)  ; Minimum TTL

                    NS      bbb

                    MX      1 alias

                    ANAME   www

    www             A       175.24.191.112

    *.wildcard      CNAME   www

    no-service 86400 IN MX 0 .
  '';
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
        # Use the MAC Address same as my iPad
        wifi = {
          macAddress = "3c:7d:0a:be:5c:98";
          scanRandMacAddress = true;
        };
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
          # ratelimit = 150;
          cache_size = 4096;
          upstreams = {
            domestic = { hybrid = [ "114DNS" "ali" ]; };

            secure = { hybrid = [ "cloudflare" "quad9" "ahadns" ]; };

            "114DNS" = { udp = { addr = "114.114.114.114:53"; }; };

            ali = { udp = { addr = "223.5.5.5:53"; }; };

            ahadns = {
              https = {
                timeout = 4;
                no_sni = true;
                name = "doh.la.ahadns.net";
                addr = "45.67.219.208:443";
              };
            };

            cloudflare = {
              https = {
                timeout = 4;
                no_sni = true;
                name = "cloudflare-dns.com";
                addr = "1.1.1.1:443";
              };
            };

            local = {
              zone = {
                origin = "a.cn";
                path = "${zonefile}";
              };
            };

            quad9 = {
              https = {
                timeout = 4;
                no_sni = true;
                name = "dns.quad9.net";
                addr = "9.9.9.9:443";
              };
            };

          };
          table = {
            start = {
              "if".qtype = [ "AAAA" ];
              "then" = [ "blackhole" "end" ];
              "else" = [ "local" ];
            };
            local = {
              "if".domain = [{ qname = "a.cn"; }];
              "then" = [ { query = "local"; } "end" ];
              "else" = [ "dispatch" ];
            };
            dispatch = {
              "if".domain = [
                { file = "${pkgs.netkit.chinalist}/google.china.raw.txt"; }
                { file = "${pkgs.netkit.chinalist}/apple.china.raw.txt"; }
                { qname = "arubanetworks.com"; }
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
            };
          };
          address = "0.0.0.0:53";
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
