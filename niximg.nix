{ config, lib, pkgs, ... }:
with lib; {

  home-manager.useUserPackages = true;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  isoImage.edition = "gnome";

  # Whitelist wheel users to do anything
  # This is useful for things like pkexec
  #
  # WARNING: this is dangerous for systems
  # outside the installation-cd and shouldn't
  # be used anywhere else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  networking.wireless.enable = mkForce false;

  services.xserver.displayManager = {
    gdm = {
      # autoSuspend makes the machine automatically suspend after inactivity.
      # It's possible someone could/try to ssh'd into the machine and obviously
      # have issues because it's inactive.
      # See:
      # * https://github.com/NixOS/nixpkgs/pull/63790
      # * https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
      autoSuspend = false;
    };
    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  x-os = {
    enable = true;
    isoMode = true;
    hostname = "niximg";
    # Use TUNA (BFSU) Mirror together with original cache because TUNA has better performance inside Mainland China.
    # Set the list to `[ ]` to use official cache only.
    binaryCaches = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
    # Choose ibus engines to apply
    ibus-engines = with pkgs.ibus-engines; [ libpinyin ];
    # Add installation script into LiveCD.
    extraPackages = [
      (pkgs.writeShellScriptBin "install-script"
        (builtins.readFile ./install.sh))
    ];
  };

  std.interface = {
    system = {
      dirs = {
        secrets.clash = "${./secrets/clash.yaml}";
        dotfiles.nixos = ./dotfiles/ash;
      };
    };
  };

  # Networking
  netkit = {
    clash = {
      enable = true;
      redirPort = 7892; # This must be the same with the one in your clash.yaml
      afterUnits = [ "smartdns.service" ];
    };

    smartdns = {
      enable = true;
      china-list = true;
      settings = {
        bind = "[::]:53";
        cache-size = 4096;
        server-https = [
          "https://cloudflare-dns.com/dns-query"
          "https://1.1.1.1/dns-query"
          "https://1.0.0.1/dns-query"
        ];
        server = [
          "114.114.114.114 -group china -exclude-default-group"
          "10.20.0.233 -group china -exclude-default-group"
          "223.5.5.5 -group china -exclude-default-group"
        ]; # Server for China-list
        prefetch-domain = true;
        speed-check-mode = "ping,tcp:80";
      };
    };
  };

  # User related section.
  hm-sanity.users = [ "nixos" ];
  users.users.nixos.shell = pkgs.zsh;
  ash-profile.nixos = {
    extraPackages = with pkgs; [
      htop
      firefox-wayland
      tdesktop
      gparted
      etcher
      torbrowser
      pavucontrol
    ];
    emacsPackages = with pkgs; [
      hunspell
      hunspellDicts.en-us-large
      emacs-all-the-icons-fonts
      ash-emacs-x86_64-linux
    ];
  };
}
