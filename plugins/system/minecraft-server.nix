{ pkgs, config, lib, ... }:

with lib;

let cfg = config.icebox.static.system.minecraft-server;
in {
  options.icebox.static.system.minecraft-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable local Minecraft Server";
    };

    port = mkOption {
      type = types.port;
      default = 25565;
      description = "Port of the server";
    };
  };

  config = mkIf (cfg.enable) {
    services.minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      openFirewall = true;
      serverProperties = {
        online-mode = false;
        server-port = cfg.port;
      };
    };
  };
}
