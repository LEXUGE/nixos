# Module of SmartDNS
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.smartdns;
  confFile = pkgs.writeText "smartdns.conf" ''
    bind :${toString cfg.bindPort}
    cache-size ${toString cfg.cacheSize}
    ${cfg.servers}
    ${cfg.extraConfig}
  '';
in {
  options.services.smartdns = {
    enable = mkEnableOption "SmartDNS DNS server";
    servers = mkOption {
      type = types.lines;
      default = "";
      description =
        "List of different DNS servers. Support UDP, TCP, TLS and HTTPS to query. See SmartDNS's readme for more info.";
    };
    cacheSize = mkOption {
      type = types.int;
      default = 512;
      description = "Domain name result cache number. Default 512.";
    };
    bindPort = mkOption {
      type = types.int;
      default = 53;
      description = "DNS listening port number. Default port 53.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description =
        "Any extra config that will be appended in configuration file";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.smartdns = {
      startLimitIntervalSec = 2;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ (import ../packages/smartdns.nix) ];
      script = "exec smartdns -c ${confFile}";

      serviceConfig = {
        Type = "forking";
        KillMode = "process";
        Restart = "always";
        RestartSec = 2;
        StartLimitBurst = 0;
      };
    };
  };
}
