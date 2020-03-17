{ config, pkgs, ... }:

let
  inherit (config.lib) system;
  inherit (config) share;
in {
  services.xserver = {
    # Start X11
    enable = true;
    dpi = system.dpi * share.scale;

    # Capslock as Control
    xkbOptions = "ctrl:nocaps";

    # Configure touchpad
    libinput = {
      enable = true;
      naturalScrolling = true;
    };

    displayManager = {
      # Add one session that would start user's own xsession profile
      session = [{
        manage = "desktop";
        name = "xsession";
        start = "exec $HOME/.xsession";
      }];
      # LightDM display manager
      lightdm = {
        enable = true;
        greeters.gtk = {
          # Set cursor size
          cursorTheme.size = system.cursorSize * share.scale;
          # Use dark them
          theme.name = "Adwaita-dark";
        };
      };
      # Startup commands
      sessionCommands = ''
        ibus-daemon -drx
      '';
    };
  };

  # Enable `light` brightness controller
  programs.light.enable = true;
}
