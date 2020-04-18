{ config, pkgs, lib, ... }:

with lib;

let
  inherit (config.icebox.static.lib.configs) system devices;
  cfg = config.icebox.static.system.x-os;
in {
  options.icebox.static.system.x-os.enable = mkOption {
    type = types.bool;
    default = false;
  };
  config = mkIf cfg.enable {
    # Use the latest linux kernel (temporarily we are using 5.5 branch because acpi_call is broken on 5.6.2)
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Add swap file
    swapDevices = [{
      device = "/var/swapFile";
      size = (devices.ramSize * 2);
    }];

    # Support NTFS
    boot.supportedFilesystems = [ "ntfs" ];

    # Auto upgrade
    system.autoUpgrade.enable = true;

    # Auto gc and optimise
    nix.optimise.automatic = true;
    nix.gc.automatic = true;
    nix.gc.options = "--delete-older-than 7d";
  };
}
