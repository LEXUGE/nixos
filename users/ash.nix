{ config, pkgs, lib, ... }:

let
  inherit (lib) mkMerge mkIf;
  inherit (config.lib.users) ash;
in mkMerge [
  (mkIf ash.enableLaTeX { # Whether install LaTeX full or not
    home-manager.users.ash.home.packages = with pkgs;
      [ texlive.combined.scheme-full ];
  })

  (mkIf ash.enable {
    # Hacky workaround of issue 948 of home-manager
    systemd.services.home-manager-ash.preStart = ''
      ${pkgs.nix}/bin/nix-env -i -E
    '';

    # System level baasic config for user.
    users.users.ash = {
      initialHashedPassword =
        "$6$2aMNNG9GcF$/5X/fdXWRl3eZXPgSRgJLplpQgjvZ4Nme6rV4mGqgoWYgQLdLwwZBsXBgjb/LQhBD31XNk0OdzWDL.ctSLiu10";
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };

    # Home-manager settings. It would be much more powerful and specific than above.
    home-manager.users.ash = {
      # User-layer packages
      home.packages = with pkgs; [
        deluge
        hunspell
        hunspellDicts.en-us-large
        zoom-us
        thunderbird
        spotify
        firefox
        tdesktop
        emacs
        minecraft
        virtmanager
      ];

      # Package settings
      programs = {
        # GNOME Terminal
        gnome-terminal = {
          enable = true;
          profile.aba3fa9f-5aab-4ce9-9775-e2c46737d9b8 = {
            default = true;
            visibleName = "Ash";
            font = "Fira Code weight=450 10";
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
          envExtra = "export QT_SCALE_FACTOR=2";
          oh-my-zsh = {
            enable = true;
            theme = "agnoster";
            plugins = [ "git" ];
          };
        };
      };

      # Handwritten configs
      home.file = {
        ".config/gtk-3.0/settings.ini".source = ../dotfiles/gtk-settings.ini;
        ".emacs.d/init.el".source = ../dotfiles/emacs.d/init.el;
        ".emacs.d/elisp/".source = ../dotfiles/emacs.d/elisp;
      };

      # Setting GNOME Dconf settings
      dconf.settings = {
        # Touchpad settings
        "org/gnome/desktop/peripherals/touchpad" = {
          disable-while-typing = false;
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        };
        # Favorite apps
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "telegram-desktop.desktop"
            "org.gnome.Nautilus.desktop"
            "org.gnome.Terminal.desktop"
            "emacs.desktop"
          ];
        };
        # Don't suspend when it is plugged in
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
        };
      };
    };
  })
]
