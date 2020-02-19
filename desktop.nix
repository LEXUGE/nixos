{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the GNOME 3
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };
}
