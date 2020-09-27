{ config, pkgs, lib, ... }:

with lib;

let cfg = config.x-os;
in {
  options.x-os = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    enableSwap = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Swap related configurations.";
    };
    isoMode = mkOption {
      type = types.bool;
      default = false;
      description =
        "Disable anything extraneous in order to build ISO image upon `installation-cd-base.nix`";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    ({
      # Temporarily switch back to kernel 5.7 branch for virtualbox
      boot.kernelPackages = pkgs.linuxPackages_5_7;

      # Support NTFS
      boot.supportedFilesystems = [ "ntfs" ];

      # Auto upgrade
      system.autoUpgrade.enable = true;

      # Auto gc and optimise
      nix.optimise.automatic = true;
      nix.gc.automatic = true;
      nix.gc.options = "--delete-older-than 7d";
    })
    (mkIf (cfg.isoMode) {
      x-os = {
        enableBoot = false;
        enableExtraServices = false;
        enableSwap = false;
      };
    })
    (mkIf (cfg.enableSwap) {
      # Add swap file
      swapDevices = [{
        device = "/var/swapFile";
        size = (config.std.interface.devices.ramSize * 2);
      }];
    })
  ]);
}
