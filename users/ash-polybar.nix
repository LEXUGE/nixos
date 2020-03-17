{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (config.lib.users) ash;
  inherit (config.lib) system;
  inherit (config) share;
in mkIf (ash.enable) {
  home-manager.users.ash.services.polybar = {
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
        green = "#34eb67";
        azure = "#3ec4d6";
        red = "#bd2c40";
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

        modules-left = "pulseaudio";
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

      "module/wlan" = {
        type = "internal/network";
        interface = "wlp0s20f3";

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
        battery = "BAT0";
        adapter = "AC";
        label-charging = "%percentage%% (%time%)";
        label-discharging = "%percentage%% (%time%)";
      };
    };

    script = ''
      polybar top &
      polybar bottom &
    '';
  };
}
