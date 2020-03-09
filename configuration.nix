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

  # Get the current release version without involving infinite recursion
  releaseVer = (import <nixpkgs/nixos> {
    configuration = { ... }: { };
  }).config.system.nixos.release;

  home-manager = builtins.fetchTarball
    "https://github.com/rycee/home-manager/archive/release-${releaseVer}.tar.gz";
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${home-manager}/nixos" # Home-manager plugin which is useful for userland configurations
  ] ++ (modulesFrom ./users) ++ (modulesFrom ./devices)
    ++ (modulesFrom ./system) ++ (modulesFrom ./modules);

  # Customized overlays
  nixpkgs.overlays = [ (import ./overlays/packages.nix) ];

  # Use TUNA Mirror together with original cache due to TUNA has better performance inside Mainland China
  nix.binaryCaches =
    [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  # Use the latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
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
