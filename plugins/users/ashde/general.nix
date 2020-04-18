{ config, pkgs, lib, ... }:

let
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
              description = "Whether to enable user <literal>ash</literal>.";
            };

            extraPackages = mkOption {
              type = with types; listOf package;
              description =
                "Extra packages to install for user <literal>ash</literal>.";
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

  config.home-manager.users = iceLib.functions.mkUserConfigs' (name: cfg: {
    # Home-manager settings.
    # User-layer packages
    home.packages = with pkgs;
      [
        hunspell
        hunspellDicts.en-us-large
        emacs
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
      ] ++ cfg.extraPackages;

    # Fontconfig
    fonts.fontconfig.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = "eog.desktop"; # `.jpg`
        "application/pdf" = "org.gnome.Evince.desktop"; # `.pdf`
      };
    };

    # Package settings
    programs = {
      alacritty = {
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
      # GnuPG
      gpg = {
        enable = true;
        settings = { throw-keyids = false; };
      };

      # Git
      git = {
        enable = true;
        userName = "Harry Ying";
        userEmail = "lexugeyky@outlook.com";
        signing = {
          signByDefault = true;
          key = "0xAE53B4C2E58EDD45";
        };
        extraConfig = { credential = { helper = "store"; }; };
      };

      # zsh
      zsh = {
        enable = true;
        # This would make C-p, C-n act exactly the same as what up/down arrows do.
        initExtra = ''
          bindkey "^P" up-line-or-search
          bindkey "^N" down-line-or-search
        '';
        # NOTE: We don't use the sessionVar option provided by home-manager, because the former one only make it available in zshrc. We need env vars everywhere.
        # GDK_SCALE: Scale the whole UI for GTK applications
        # GDK_DPI_SCALE: Scale the fonts back for GTK applications to avoid double scaling
        # QT_AUTO_SCREEN_SCALE_FACTOR: Let QT auto detect the DPi
        envExtra = ''
          export GDK_SCALE=${toString system.scale}
          export GDK_DPI_SCALE=${toString (1.0 / system.scale)}
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
        '';
        defaultKeymap = "emacs";
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [ "git" ];
        };
      };
    };

    # Handwritten configs
    home.file = {
      ".config/gtk-3.0/settings.ini".source =
        (system.dirs.dotfiles + /ash/gtk-settings.ini);
      ".emacs.d/init.el".source =
        (system.dirs.dotfiles + "/${name}/emacs.d/init.el");
      ".emacs.d/elisp/".source =
        (system.dirs.dotfiles + "/${name}/emacs.d/elisp");
    };

    # Dconf settings
    dconf.settings = {
      "desktop/ibus/general/hotkey" = {
        triggers = [ "<Control><Shift>space" ];
      };
    };
  }) config.icebox.static.users.ashde;
}
