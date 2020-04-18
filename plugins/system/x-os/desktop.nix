{ config, pkgs, lib, ... }:

let
  inherit (config.icebox.static.lib.configs.system) dpi scale cursorSize;
  cfg = config.icebox.static.system.x-os;
in lib.mkIf cfg.enable {
  services.xserver = {
    # Start X11
    enable = true;
    dpi = dpi * scale;

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
          cursorTheme.size = cursorSize * scale;
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
