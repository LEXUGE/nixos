{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.ir-toggle;
in {
  options = {
    services.ir-toggle = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Chicony IR Emitter toggler.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    # Udev rules to start it on boot.
    environment.systemPackages = [ pkgs.ir_toggle ];
    # Re-toggle the IR emitter after the sleep so that it could work perfectly
    powerManagement.resumeCommands =
      "${pkgs.ir_toggle}/bin/chicony-ir-toggle on";
    services.udev.packages = [ pkgs.ir_toggle ];
  };
}
