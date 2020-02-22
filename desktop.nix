{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkbOptions =
    "ctrl:nocaps"; # The GNOME on Wayland would use this setting if there is no xkb setting has been set. Else you need to reset the key in gsettings.

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the GNOME 3
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };
}
