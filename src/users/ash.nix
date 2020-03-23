{ config, pkgs, lib, ... }:

let
  inherit (config.local) share;
  cfg = config.local.users.ash;
in lib.mkIf cfg.enable {
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
    # wheel - sudo
    # networkmanager - manage network
    # video - light control
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # Install packages to `/etc/profile` because upstream would default it in the future.
  home-manager.useUserPackages = true;

  # Home-manager settings. It would be much more powerful and specific than above.
  home-manager.users.ash = {
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
      ] ++ cfg.extraPackages;

    # Fontconfig
    fonts.fontconfig.enable = true;

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
          env = { WINIT_HIDPI_FACTOR = toString share.scale; };
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
        # GDK_SCALE: Scale the whole UI for GTK applications
        # GDK_DPI_SCALE: Scale the fonts back for GTK applications to avoid double scaling
        # QT_SCALE_FACTOR: Scale the whole UI for QT applications
        envExtra = ''
          export GDK_SCALE=${toString share.scale}
          export GDK_DPI_SCALE=${toString (1.0 / share.scale)}
          export QT_SCALE_FACTOR=${toString share.scale}
        '';
        # This would make C-p, C-n act exactly the same as what up/down arrows do.
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
        ../../dotfiles/ash/gtk-settings.ini;
      ".emacs.d/init.el".source = ../../dotfiles/ash/emacs.d/init.el;
      ".emacs.d/elisp/".source = ../../dotfiles/ash/emacs.d/elisp;
    };

    # Dconf settings
    dconf.settings = {
      "desktop/ibus/general/hotkey" = {
        triggers = [ "<Control><Shift>space" ];
      };
    };
  };
}
