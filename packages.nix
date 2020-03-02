{ config, pkgs, ... }:

let
  unstable = import <unstable> { };
  unstable-nonfree = import <unstable> { config.allowUnfree = true; };
in {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    emacs
    nixfmt
    firefox
    tdesktop
    git
    gnupg
    spotify
    shadowsocks-libev
    (import ./packages/simple-obfs.nix)
    (import ./packages/smartdns.nix)
    fwupd
    thunderbird
    neofetch
    zoom-us
    bind
    texlive.combined.scheme-full
    usbutils
    shfmt
    shellcheck
    deluge
    hunspell
    hunspellDicts.en-us-large
    smartmontools
    pavucontrol
    gnome3.gnome-tweaks
    efibootmgr
  ];

  # Virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "ash" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;

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
