# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Following are my own config
    ./networking.nix # Network settings
    ./boot.nix # Bootloader settings
    ./packages.nix # All packages and there settings
    ./desktop.nix # For X system and DE
    ./service.nix # Various services like sound, printer, etc.
    ./user.nix # User and its specifics
    ./home.nix # home-manager related stuff
    ./auto-update.nix # Faultless auto update from Jollheef
    ./nesting.nix # Nesting function dedicates to provide transparent proxy switch
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

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
