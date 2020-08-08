{ config, pkgs, lib, ... }:

let cfg = config.x-os;
in lib.mkIf cfg.enable {
  services.xserver = {
    # Start X11
    enable = true;

    # Capslock as Control
    xkbOptions = "ctrl:nocaps";

    # Configure touchpad
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
  };
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Some of the GNOME Packages are unwanted
  programs.geary.enable = false;
  environment.gnome3.excludePackages =
    [ pkgs.gnome3.epiphany pkgs.gnome3.gnome-software ];
}
