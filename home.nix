{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "621c98f15a31e7f0c1389f69aaacd0ac267ce29e";
  };
in {
  imports = [ "${home-manager}/nixos" ]; # Import home-manager

  # Hacky workaround of issue 948 of home-manager
  systemd.services.home-manager-ash.preStart = ''
    ${pkgs.nix}/bin/nix-env -i -E
  '';

  home-manager.users.ash = {
    # User-layer packages
    home.packages = with pkgs; [ hello ];

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
      };

      # zsh
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [ "git" ];
        };
      };
    };

    # Handwritten configs
    home.file = {
      ".config/gtk-3.0/settings.ini".source = ./dotfiles/gtk-settings.ini;
    };

    # Setting GNOME Dconf settings
    dconf.settings = {
      # Touchpad settings
      "org/gnome/desktop/peripherals/touchpad" = {
        disable-while-typing = false;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      # Keymapping (doesn't work yet)
      # "org/gnome/desktop/input-sources/xkb-options" = [ "ctrl:nocaps" ];
    };
  };
}
