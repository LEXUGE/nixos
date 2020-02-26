{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.smartdns;
  mkServerConfig = method:
    mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of servers to query with ${
          toUpper method
        } method. You can apply different options at here too. See the <link xlink:href="https://github.com/pymumu/smartdns/blob/master/ReadMe_en.md#configuration-parameter">SmartDNS README</link> for details.
      '';
    };

  confFile = pkgs.writeText "smartdns.conf" ''
    bind :${toString cfg.bindPort}
    cache-size ${toString cfg.cacheSize}
    ${flip concatMapStrings cfg.servers-udp (server: ''
      server-udp ${server}
    '')}
    ${flip concatMapStrings cfg.servers-tcp (server: ''
      server-tcp ${server}
    '')}
    ${flip concatMapStrings cfg.servers-tls (server: ''
      server-tls ${server}
    '')}
    ${flip concatMapStrings cfg.servers-https (server: ''
      server-https ${server}
    '')}
    ${cfg.extraConfig}
  '';
in {
  options.services.smartdns = {
    enable = mkEnableOption "SmartDNS DNS server";

    servers-udp = mkServerConfig "udp";
    servers-tcp = mkServerConfig "tcp";
    servers-tls = mkServerConfig "tls";
    servers-https = mkServerConfig "https";

    cacheSize = mkOption {
      type = types.int;
      default = 512;
      description = "Domain name result cache number.";
    };

    bindPort = mkOption {
      type = types.int;
      default = 53;
      description = "DNS listening port number.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Any extra parameters that will be appended to configuration file, see the <link xlink:href="https://github.com/pymumu/smartdns/blob/master/ReadMe_en.md#configuration-parameter">SmartDNS README</link> for details.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ (import ../packages/smartdns.nix) ];
    environment.etc."smartdns/smartdns.conf".source = confFile;
    environment.etc."default/smartdns" = {
      mode = "0644";
      source = "${(import ../packages/smartdns.nix)}/etc/default/smartdns";
    };
  };
}
