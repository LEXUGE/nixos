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
        extraGroups = [ "wheel" "networkmanager" "wireshark" ];
      };
    };
  };

  ash-profile.ash = {
    emacsPackages = with pkgs; [
      (hunspellWithDicts [ hunspellDicts.en-us hunspellDicts.en-us-large ])
      emacs-all-the-icons-fonts
      ash-emacs-x86_64-linux
    ];
    extraPackages = with pkgs; [
      #(python3.withPackages (ps: [ ps.tkinter ]))
      htop
      qbittorrent
      zoom-us
      thunderbird-bin-78
      #tor-browser-bundle-bin
      spotify
      remmina
      firefox-wayland
      aria2
      # chromium
      tdesktop
      minecraft
      biber
      zotero
      (texlive.combine {
        inherit (texlive)
          scheme-basic chktex
          # org-mode
          wrapfig ulem capt-of metafont
          # MLA Formatted Paper
          setspace mla-paper thumbpdf times
          # BiBLaTeX
          biblatex-mla biblatex csquotes;
      })
      # Steam scaling seems to be broken, doing it manually
      (runCommand "steam-hidpi" { nativeBuildInputs = [ makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper ${steam}/bin/steam $out/bin/steam --set GDK_SCALE ${
          toString config.std.interface.system.scale
        }
        cp -r ${steam}/share $out/share/
      '')
      gparted
      etcher
      gnome-podcasts
      gnome3.gnome-sound-recorder
      frp
      vlc
      dogdns
      pavucontrol
      # torbrowser
      ifuse
      libimobiledevice
      onlyoffice-bin
      fawkes
      wolfram-engine
      dnsperf
      # nix-search
    ];
  };
}
