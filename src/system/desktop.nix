{ config, pkgs, lib, ... }:

let
  inherit (config.local) share;
  cfg = config.local.system;
in {
  services.xserver = {
    # Start X11
    enable = true;
    dpi = cfg.dpi * share.scale;

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
          cursorTheme.size = cfg.cursorSize * share.scale;
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
