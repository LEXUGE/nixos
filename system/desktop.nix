{ config, pkgs, ... }:

{
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
          cursorTheme.size = 32;
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
