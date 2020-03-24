{ config, pkgs, lib, ... }:

let
  inherit (config.local) share system;
  cfg = config.local.users.ash;
in lib.mkIf cfg.enable {
  home-manager.users.ash = {
    services.polybar = {
      # Polybar
      enable = true;

      package = pkgs.polybar.override {
        i3GapsSupport = true;
        pulseSupport = true;
      };

      config = let interval = 5;
      in {
        "colors" = {
          black = "#222";
          grey = "#444";
          green = "#2ff923";
          azure = "#1febfd";
          red = "#ff0000";
        };

        "bar/top" = {
          dpi = share.scale * system.dpi;
          width = "100%";
          height = "2.7%";

          modules-left = "i3";
          modules-center = "date";
          modules-right = "memory wlan battery";
          # Number of spaces between modules
          module-margin = 2;

          font-0 = "Fira Code:style=regular:size=10:antialias=true;1";
          font-1 = "Material Icons:size=10;4";

          line-size = 3;

          background = "\${colors.black}";
        };

        "bar/bottom" = {
          dpi = share.scale * system.dpi;
          width = "100%";
          height = "2.7%";

          bottom = true;

          modules-left = "cpu filesystem pulseaudio power";
          tray-position = "right";
          # Number of spaces between modules
          module-margin = 2;

          font-0 = "Fira Code:style=regular:size=10:antialias=true;1";
          font-1 = "Material Icons:size=10;4";

          line-size = 3;

          background = "\${colors.black}";
        };

        "module/date" = {
          type = "internal/date";
          interval = interval;
          date = "%m/%d/%y";
          time = "%H:%M";
          label = "%time%  %date%";
        };

        "module/memory" = {
          type = "internal/memory";
          format-underline = "\${colors.green}";
          label = "RAM:%percentage_used%%";
          interval = interval;
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          label-volume = "VOL %percentage%%";
          label-volume-underline = "\${colors.green}";
          label-muted = "Muted";
        };

        "module/i3" = {
          type = "internal/i3";
          format = "<label-state> <label-mode>";
          index-sort = "true";
          wrapping-scroll = "false";

          # Only show workspaces on the same output as the bar
          # pin-workspaces = true

          # focused = Active workspace on focused monitor
          label-focused = "%index%";
          label-focused-background = "\${colors.grey}";
          label-focused-underline = "\${colors.azure}";
          label-focused-padding = 2;

          # unfocused = Inactive workspace on any monitor
          label-unfocused = "%index%";
          label-unfocused-padding = 2;

          # visible = Active workspace on unfocused monitor
          label-visible = "%index%";
          label-visible-background = "\${self.label-focused-background}";
          label-visible-underline = "\${self.label-focused-underline}";
          label-visible-padding = "\${self.label-focused-padding}";

          # urgent = Workspace with urgency hint set
          label-urgent = "%index%";
          label-urgent-background = "\${colors.red}";
          label-urgent-padding = 2;
        };

        "module/cpu" = {
          type = "internal/cpu";
          format-underline = "\${colors.green}";
          label = "CPU:%percentage%%";
        };

        "module/filesystem" = {
          type = "internal/fs";
          mount-0 = "/";
          label-mounted = "%mountpoint%:%free%";
          format-mounted-underline = "\${colors.green}";
        };

        "module/wlan" = {
          type = "internal/network";
          interface = cfg.network-interface;

          # Contents to show when network is connected
          label-connected = "%essid%+%downspeed%-%upspeed%";
          format-connected-underline = "\${colors.green}";
          # Contents to show when network is disconnected
          label-disconnected = "Disconnected";
          format-disconnected-background = "\${colors.red}";

          interval = interval;
        };

        "module/battery" = {
          type = "internal/battery";
          full-at = 99;
          time-format = "%H:%M";
          battery = cfg.battery;
          adapter = cfg.power;
          label-charging = "%percentage%% (%time%)";
          label-discharging = "%percentage%% (%time%)";
        };

        "module/power" = {
          type = "custom/menu";
          expand-right = true;
          format-spacing = 1;
          label-separator = "|";
          label-open = "Power";
          label-open-underline = "\${colors.red}";
          label-close = "Cancel";
          label-close-underline = "\${colors.green}";

          menu-0-0 = "Reboot";
          menu-0-0-exec = "menu-open-1";
          menu-0-0-underline = "\${colors.red}";
          menu-0-1 = "Power off";
          menu-0-1-exec = "menu-open-2";
          menu-0-1-underline = "\${colors.red}";
          menu-0-2 = "Hibernate";
          menu-0-2-exec = "menu-open-3";
          menu-0-2-underline = "\${colors.red}";
          menu-0-3 = "Exit i3";
          menu-0-3-exec = "menu-open-4";
          menu-0-3-underline = "\${colors.red}";

          menu-1-0 = "Back";
          menu-1-0-exec = "menu-open-0";
          menu-1-0-underline = "\${colors.green}";
          menu-1-1 = "Reboot";
          menu-1-1-underline = "\${colors.red}";
          menu-1-1-exec = "${pkgs.systemd}/bin/systemctl reboot";

          menu-2-0 = "Back";
          menu-2-0-exec = "menu-open-0";
          menu-2-0-underline = "\${colors.green}";
          menu-2-1 = "Power off";
          menu-2-1-underline = "\${colors.red}";
          menu-2-1-exec = "${pkgs.systemd}/bin/systemctl poweroff";

          menu-3-0 = "Back";
          menu-3-0-exec = "menu-open-0";
          menu-3-0-underline = "\${colors.green}";
          menu-3-1 = "Hibernate";
          menu-3-1-underline = "\${colors.red}";
          menu-3-1-exec = "${pkgs.systemd}/bin/systemctl hibernate";

          menu-4-0 = "Back";
          menu-4-0-exec = "menu-open-0";
          menu-4-0-underline = "\${colors.green}";
          menu-4-1 = "Exit i3";
          menu-4-1-underline = "\${colors.red}";
          menu-4-1-exec = "i3-msg exit";
        };
      };

      # Start up script for polybar
      script = ''
        polybar top &
        polybar bottom &
      '';
    };
  };
}
