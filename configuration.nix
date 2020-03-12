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
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${home-manager}/nixos" # Home-manager plugin which is useful for userland configurations
  ] ++ (modulesFrom ./users) ++ (modulesFrom ./devices)
    ++ (modulesFrom ./system) ++ (modulesFrom ./modules);

  # Customized overlays
  nixpkgs.overlays = [ (import ./overlays/packages.nix) ];

  # Customized binary caches list (with fallback to official binary cache)
  nix.binaryCaches = config.lib.system.binaryCaches;

  # Use the latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Select internationalisation properties.
  console.font = "Lat2-Terminus16";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
  };

  # Add swap file (8GB)
  swapDevices = [{
    device = "/var/swapFile";
    size = 8192;
  }];

  # Support NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

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
