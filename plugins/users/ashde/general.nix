{ config, pkgs, lib, ... }:

with lib;

let
  inherit (config.icebox.static.lib.configs.system) dpi scale cursorSize;
  inherit (config.icebox.static.lib.configs) system devices;
  iceLib = config.icebox.static.lib;
in {
  options.icebox.static.users.ashde = with lib;
    mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
              example = true;
              description =
                "Whether to enable DE customized by user <literal>ash</literal>.";
            };

            battery = mkOption {
              type = types.enum devices.battery;
              description =
                "Battery name under <literal>/sys/class/power_supply/</literal> used by polybar <literal>battery</literal> module. Choose one in <option>options.icebox.devices.battery</option>";
            };

            power = mkOption {
              type = types.enum devices.power;
              description =
                "AC power adapter name under <literal>/sys/class/power_supply/</literal> used by polybar <literal>battery</literal> module. Choose one in <option>options.icebox.devices.power</option>";
            };

            network-interface = mkOption {
              type = types.enum devices.network-interface;
              description = "Network interface name to monitor on bar";
            };
          };
        });
      default = { };
    };

  config.services.xserver =
    mkIf (iceLib.functions.anyEnabled config.icebox.static.users.ashde) {
      dpi = dpi * scale;

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

  config.programs.light.enable =
    mkIf (iceLib.functions.anyEnabled config.icebox.static.users.ashde) true;

  config.home-manager.users = iceLib.functions.mkUserConfigs' (name: cfg: {
    # NOTE: We don't use the sessionVar option provided by home-manager, because the former one only make it available in zshrc. We need env vars everywhere.
    # GDK_SCALE: Scale the whole UI for GTK applications
    # GDK_DPI_SCALE: Scale the fonts back for GTK applications to avoid double scaling
    # QT_AUTO_SCREEN_SCALE_FACTOR: Let QT auto detect the DPi
    home.sessionVariables = {
      GDK_SCALE = "${toString system.scale}";
      GDK_DPI_SCALE = "${toString (1.0 / system.scale)}";
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    };

    home.packages = with pkgs; [
      i3lock
      xss-lock
      xautolock
      escrotum
      dmenu
      libnotify
      gnome3.file-roller
      gnome3.nautilus
      gnome3.eog
      evince
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "Fira Code Retina";
            style = "Regular";
          };
        };
        env = { WINIT_HIDPI_FACTOR = toString system.scale; };
      };
    };

    # Fontconfig
    fonts.fontconfig.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = "eog.desktop"; # `.jpg`
        "application/pdf" = "org.gnome.Evince.desktop"; # `.pdf`
      };
    };

    # Dconf settings
    dconf.settings = {
      "desktop/ibus/general/hotkey" = {
        triggers = [ "<Control><Shift>space" ];
      };
    };
  }) config.icebox.static.users.ashde;
}
