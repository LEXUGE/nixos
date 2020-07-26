{ config, pkgs, lib, ... }:

with lib;

let cfg = config.icebox.static.system.x-os;
in {
  options.icebox.static.system.x-os = {
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
      type = with types; attrsOf (attrsOf (oneOf [ bool int str ]));
      default = { };
      description = "Configuratoin of iNet Wireless Daemon.";
    };
  };
  config = mkIf cfg.enable {
    networking.hostName = cfg.hostname; # Define hostname

    networking.networkmanager = {
      # Enable networkmanager. REMEMBER to add yourself to group in order to use nm related stuff.
      enable = true;
      # Don't use DNS advertised by connected network. Use local configuration
      dns = "none";
      # Use iwd instead
      wifi.backend = "iwd";
    };

    environment.etc."iwd/main.conf".text = generators.toINI { } cfg.iwdConfig;

    # Customized binary caches list (with fallback to official binary cache)
    nix.binaryCaches = cfg.binaryCaches;

    # Use local DNS server all the time
    networking.resolvconf.useLocalResolver = true;
  };
}
