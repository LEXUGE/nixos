{ config, pkgs, lib, ... }:
let
  moz_overlay = import (builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");
  home-manager = builtins.fetchTarball
    "https://github.com/rycee/home-manager/archive/master.tar.gz";
  icebox = builtins.fetchTarball
    "https://github.com/LEXUGE/icebox/archive/master.tar.gz";
in {
  imports = [
    ./hardware-configuration.nix
    "${icebox}"
    ./plugins
    "${home-manager}/nixos"
  ];

  home-manager.useUserPackages = true;

  icebox = {
    users = {
      plugins = [ "ashde" "hm-fix" "ash-profile" ];
      users = {
        ash = {
          regular = {
            hashedPassword =
              "$6$FAs.ZfxAkhAK0ted$/aHwa39iJ6wsZDCxoJVjedhfPZ0XlmgKcxkgxGDE.hw3JlCjPHmauXmQAZUlF8TTUGgxiOJZcbYSPsW.QBH5F.";
            shell = pkgs.zsh;
            isNormalUser = true;
            # wheel - sudo
            # networkmanager - manage network
            # video - light control
            # libvirtd - virtual manager controls.
            extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
          };
          configs = {
            ash-profile = {
              enable = true;
              extraPackages = with pkgs; [
                htop
                deluge
                zoom-us
                thunderbird
                spotify
                firefox
                tdesktop
                minecraft
                virtmanager
                texlive.combined.scheme-full
                #steam
                etcher
                vlc
                pavucontrol
                calibre
                tor-browser-bundle-bin
                latest.rustChannels.stable.rust
              ];
            };
            ashde = {
              enable = false;
              # Adapt followings to what your device profile supplied
              battery = "BAT0";
              power = "AC";
              network-interface = "wlp0s20f3";
            };
          };
        };
      };
    };

    devices = {
      plugins = [ "x1c7" "howdy" ];
      configs = {
        x1c7 = {
          enable = true;
          # Choose "howdy", "fprintd", or null.
          bio-auth = "howdy";
        };
        # x1c7 would automatically enable howdy and set necessary configuratons.
        howdy.pamServices = [ "sudo" "login" "polkit-1" "i3lock" ];
      };
    };

    lib = {
      modules = [ (import ./plugins/lib/modules/std.nix { lib = lib; }) ];
      configs = {
        system = {
          # Path to directories (use relative paths to avoid trouble in nixos-install.)
          # If you don't understand, just keep it as it is.
          dirs = {
            secrets = ./secrets; # Did you read the comments above?
            dotfiles = ./dotfiles;
          };
          bluetooth = {
            # Force enable/disable bluetooth
            # enable = true;
            # Choose default bluetooth service
            service = "blueman";
          };
        };
        devices = {
          # resume_offset value. Obtained by <literal>filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }'</literal>
          # If you want to hibernate, you MUST set it properly.
          swapResumeOffset = 36864;
        };
      };
    };

    system = {
      plugins = [ "x-os" "gnome" "clash" ];
      stateVersion = "19.09";
      configs = {
        x-os = {
          enable = true;
          hostname = "nixos";
          # Use TUNA Mirror together with original cache because TUNA has better performance inside Mainland China.
          # Set the list to `[ ]` to use official cache only.
          binaryCaches =
            [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
          # Choose ibus engines to apply
          ibus-engines = with pkgs.ibus-engines; [ libpinyin ];
        };
        gnome.enable = true;
        clash = {
          enable = true;
          redirPort =
            7892; # This must be the same with the one in your clash.yaml
        };
      };
    };

    overlays = [ moz_overlay ];
  };
}
