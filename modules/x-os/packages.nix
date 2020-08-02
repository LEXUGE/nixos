{ config, lib, pkgs, ... }:

with lib;

let cfg = config.x-os;
in mkIf cfg.enable {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    nixfmt
    git
    gnupg
    neofetch
    busybox
    shfmt
    shellcheck
    smartmontools
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
