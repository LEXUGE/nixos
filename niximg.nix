{ config, pkgs, lib, ... }:

{
  home-manager.useUserPackages = true;

  networking.wireless.enable = lib.mkForce false;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  std = {
    system = {
      dirs = {
        secrets = ./secrets;
        dotfiles = ./dotfiles;
      };
    };
    devices = { ramSize = 4096; };
  };

  x-os = {
    enable = true;
    hostname = "niximg";
    noBoot = true;
    # Use TUNA (BFSU) Mirror together with original cache because TUNA has better performance inside Mainland China.
    # Set the list to `[ ]` to use official cache only.
    binaryCaches = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
    # Choose ibus engines to apply
    ibus-engines = with pkgs.ibus-engines; [ libpinyin ];
    # iwdConfig = { General = { UseDefaultInterface = true; }; };
  };

  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword =
        "$6$TqNkihvO4K$x.qSUVbLQ9.IfAc9tOQawDzVdHJtQIcKrJpBCBR.wMuQ8qfbbbm9bN7JNMgneYnNPzAi2k9qXk0klhTlRgGnk0";
      ash = {
        hashedPassword =
          "$6$FAs.ZfxAkhAK0ted$/aHwa39iJ6wsZDCxoJVjedhfPZ0XlmgKcxkgxGDE.hw3JlCjPHmauXmQAZUlF8TTUGgxiOJZcbYSPsW.QBH5F.";
        shell = pkgs.zsh;
        isNormalUser = true;
        # wheel - sudo
        # networkmanager - manage network
        # video - light control
        # libvirtd - virtual manager controls.
        extraGroups = [ "wheel" "networkmanager" "video" ];
      };
    };
  };

  ash-profile.ash = {
    extraPackages = with pkgs; [
      htop
      deluge
      thunderbird
      firefox-wayland
      tdesktop
      gparted
      etcher
      pavucontrol
    ];
  };

  netkit.clash = {
    enable = true;
    redirPort = 7892; # This must be the same with the one in your clash.yaml
  };
}
