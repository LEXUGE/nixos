# i3wm related settings for user ash

{ config, pkgs, lib, ... }:

let
  inherit (config.local) share system;

  cfg = config.local.users.ash;
  lock = "${pkgs.i3lock}/bin/i3lock -c 000000";
in lib.mkIf (cfg.enable) {
  home-manager.users.ash = {
    # Compton compositor
    services.compton = {
      enable = true;
      # vertical sync to avoid screen tearing
      vSync = "opengl-swc";
    };

    # Rofi
    programs.rofi = {
      enable = true;
      font = "Fira Code 10";
      theme = "glue_pro_blue";
      extraConfig = ''
        rofi.show-icons: true
        rofi.dpi: ${toString (share.scale * system.dpi)}
      '';
    };

    services.screen-locker = {
      enable = true;
      lockCmd = lock;
    };

    # Xsession
    xsession = {
      enable = true;

      # Enable i3
      windowManager.i3 = {
        enable = true;
        config = {
          terminal = "alacritty";

          gaps = {
            smartGaps = true;
            smartBorders = "on";
            inner = 5;
            outer = 5;
          };

          bars = [ ];

          startup = [{
            command = "systemctl --user restart polybar";
            always = true;
            notification = false;
          }];

          # Don't conflict with emacs
          modifier = "Mod4";

          keybindings = let
            modifier =
              config.home-manager.users.ash.xsession.windowManager.i3.config.modifier;
          in lib.mkOptionDefault {
            # Setup multimedia keys
            "XF86MonBrightnessUp" = " exec --no-startup-id light -A 5";
            "XF86MonBrightnessDown" = "exec --no-startup-id light -U 5";
            "XF86AudioRaiseVolume" =
              "exec --no-startup-id pactl set-sink-volume 0 +5%";
            "XF86AudioLowerVolume" =
              "exec --no-startup-id pactl set-sink-volume 0 -5%";
            "XF86AudioMute" =
              "exec --no-startup-id pactl set-sink-mute 0 toggle";

            # Shift focus
            "${modifier}+j" = "focus left";
            "${modifier}+k" = "focus down";
            "${modifier}+l" = "focus up";
            "${modifier}+semicolon" = "focus right";

            "${modifier}+n" = "exec --no-startup-id ${lock}";

            # Rofi run by zsh because we need environments
            "${modifier}+d" = ''
              exec "zsh -c 'rofi -combi-modi window,drun -show combi -modi combi'"'';

            # Screenshot
            "--release Shift+Print" =
              "exec escrotum -C"; # Screenshot the whole screen and copy to clipboard
            "--release Shift+Control+Print" =
              "exec escrotum -Cs"; # Screenshot a selected area and copy to clipboard
            "--release Control+Print" =
              "exec escrotum -s"; # Screenshot a selected area and save it.
            "--release Print" =
              "exec escrotum"; # Screenshot whole screen and save it.
          };
        };
      };

      # Setup cursor
      pointerCursor = {
        package = pkgs.gnome3.adwaita-icon-theme;
        name = "Adwaita";
        size = system.cursorSize * share.scale;
      };
    };
  };
}
