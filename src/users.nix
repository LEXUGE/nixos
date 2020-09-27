{ config, pkgs, ... }: {
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
        # docker - Docker control
        extraGroups = [ "wheel" "networkmanager" "docker" ];
      };
    };
  };

  hm-sanity.users = [ "ash" ];

  ash-profile.ash = {
    emacsPackages = with pkgs; [
      hunspell
      hunspellDicts.en-us-large
      emacs-all-the-icons-fonts
      ash-emacs-x86_64-linux
    ];
    extraPackages = with pkgs; [
      #(python3.withPackages (ps: [ ps.tkinter ]))
      htop
      qbittorrent
      #zoom-us
      thunderbird-bin-78
      spotify
      firefox-wayland
      (chromium.override { enableVaapi = true; })
      tdesktop
      multimc
      (texlive.combine {
        inherit (texlive) scheme-basic wrapfig ulem capt-of metafont;
      })
      steam
      gparted
      etcher
      gnome-podcasts
      gnome3.gnome-sound-recorder
      frp
      pavucontrol
      torbrowser
      ifuse
      libimobiledevice
      #onlyoffice-desktop
    ];
  };
}
