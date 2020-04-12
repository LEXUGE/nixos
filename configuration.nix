# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # Import all the nix files in a folder
  modulesFrom = dir:
    map (f: dir + "/${f}") (builtins.attrNames
      (lib.filterAttrs (n: v: (v == "regular") && (lib.hasSuffix ".nix" n))
        (builtins.readDir dir)));

  home-manager = builtins.fetchTarball
    "https://github.com/rycee/home-manager/archive/master.tar.gz";

  moz_overlay = import (builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

  inherit (config.local) system share;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${home-manager}/nixos" # Home-manager plugin which is useful for userland configurations
    ./local.nix # Options for whole system configuraions.
  ] ++ builtins.concatLists (map modulesFrom [
    ./src/users # Userland configuration profiles.
    ./src/devices # Device specific configuration profiles.
    ./src/system # System wide configuraions.
    ./modules/packages # Module for packages.
    ./modules/local # Module for local options.
    ./modules/local/users # Module for user profile options, located under local module.
    ./modules/local/devices # Module for device profile options, located under local module.
  ]);

  # Customized overlays
  nixpkgs.overlays = [ (import ./overlays/packages.nix) moz_overlay ];

  # Customized binary caches list (with fallback to official binary cache)
  nix.binaryCaches = system.binaryCaches;

  # Use the latest linux kernel (temporarily we are using 5.5 branch because acpi_call is broken on 5.6.2)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Add swap file
  swapDevices = [{
    device = "/var/swapFile";
    size = (share.ramSize * 2);
  }];

  # Support NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  # Auto upgrade
  system.autoUpgrade.enable = true;

  # Auto gc and optimise
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
