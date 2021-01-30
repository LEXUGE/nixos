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
      touchpad.naturalScrolling = true;
    };
  };
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Some of the GNOME Packages are unwanted
  programs.geary.enable = false;
  environment.gnome3.excludePackages = with pkgs.gnome3; [
    epiphany
    gnome-software
    gnome-characters
  ];
  # Fix "a stop job is runnig" issue, see also https://gitlab.gnome.org/GNOME/gnome-session/-/merge_requests/55/diffs. This should be removed once `gnome-session is upgraded.
  systemd.user.services.gnome-session-restart-dbus.serviceConfig.Slice =
    "-.slice";
}
