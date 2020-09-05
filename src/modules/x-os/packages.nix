{ config, lib, pkgs, ... }:

with lib;

let cfg = config.x-os;
in {
  options.x-os.extraPackages = mkOption {
    type = with types; nullOr (listOf package);
    default = null;
    description = "Extra packages to install for the whole system.";
  };
  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
      [
        wget
        nixfmt
        git
        gnupg
        neofetch
        bind
        busybox
        shfmt
        shellcheck
        smartmontools
        efibootmgr
        rsync
        ncdu
      ] ++ optionals (cfg.extraPackages != null) cfg.extraPackages;

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
  };
}
