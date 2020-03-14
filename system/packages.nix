{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    nixfmt
    git
    gnupg
    shadowsocks-libev
    simple-obfs
    neofetch
    bind
    usbutils
    pciutils
    shfmt
    shellcheck
    smartmontools
    pavucontrol
    gnome3.gnome-tweaks
    efibootmgr
    ncdu
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];

  # Setup zsh
  programs.zsh.enable = true;
}
