{ config, pkgs, ... }:

{
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
    fwupd
    thunderbird
    neofetch
    zoom-us
  ];

  # Fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];

  programs.dconf.enable = true;

  # Setup zsh
  programs.zsh.enable = true;
}
