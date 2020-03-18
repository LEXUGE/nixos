{ config, pkgs, lib, ... }:

let
  inherit (config.meta) share;
  cfg = config.meta.users.ash;
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
      [ hunspell hunspellDicts.en-us-large i3lock xss-lock xautolock ]
      ++ cfg.extraPackages;

    # Fontconfig
    fonts.fontconfig.enable = true;

    # Enable QT configuration to make it fits in
    qt = {
      enable = true;
      platformTheme = "gnome";
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
