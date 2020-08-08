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
      # Use the latest linux kernel (temporarily we are using 5.6 branch because swapfile fails on 5.7 https://bugzilla.kernel.org/show_bug.cgi?id=207585#c5)
      boot.kernelPackages = pkgs.linuxPackages_latest;

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
        size = (config.std.devices.ramSize * 2);
      }];
    })
  ]);
}
