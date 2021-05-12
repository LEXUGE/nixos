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
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Support NTFS
      boot.supportedFilesystems = [ "ntfs" ];

      # Auto upgrade
      # system.autoUpgrade.enable = true;

      # Use nix-unstable
      nix.package = pkgs.nixUnstable;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';

      # setup default registry for nix-dram
      # nix.registry.default = {
      #   to = {type= "github"; owner= "NixOS"; repo= "nixpkgs"; ref = "nixos-unstable";};
      #   from = {type = "indirect"; id = "default";};
      # };

      # Auto gc and optimise
      nix.optimise.automatic = true;
      nix.gc.automatic = false;
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
