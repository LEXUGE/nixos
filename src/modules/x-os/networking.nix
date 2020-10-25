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
      netkit.atomdns = {
        enable = true;
        settings = ''
          listen = "0.0.0.0:53"

          upstream "oversea" {
            type = "dot"
            addr = "9.9.9.9:853"
          }

          upstream "mainland" {
            type = "udp"
            addr = "114.114.114.114:53"
          }

          match "accelerated" {
            type = "in_domain_list"
            path = "${pkgs.chinalist-raw}/accelerated-domains.china.raw.txt"
          }

          match "google" {
            type = "in_domain_list"
            path = "${pkgs.chinalist-raw}/google.china.raw.txt"
          }

          match "apple" {
            type = "in_domain_list"
            path = "${pkgs.chinalist-raw}/apple.china.raw.txt"
          }

          rules = {
            accelerated: "mainland",
            google: "mainland",
            apple: "mainland",
            default: "oversea"
          }
        '';
      };
    })

    (mkIf (cfg.iwdConfig != null) {
      environment.etc."iwd/main.conf".text = generators.toINI { } cfg.iwdConfig;
      networking.networkmanager.wifi.backend = "iwd";
    })
  ]);
}
