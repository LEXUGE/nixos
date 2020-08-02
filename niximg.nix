{ config, pkgs, lib, ... }:

{
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  std = {
    system = { dirs = { secrets = ./secrets; }; };
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
    users = {
      root.hashedPassword =
        "$5$a5/kwPSEATbi09us$tFaomvn2aSyBp1YG.kMBKlp1s1qcya6/iK31hSkcFR1";
      nixos = {
        hashedPassword =
          "$5$9FOksW6qEC0Zjuc1$j92QwubbVg0qMgn6bRovVY5eIefyoPIXwN5CTP89yi.";
        shell = pkgs.zsh;
        isNormalUser = true;
        # wheel - sudo
        # networkmanager - manage network
        # video - light control
        # libvirtd - virtual manager controls.
        extraGroups = [ "wheel" "networkmanager" ];
      };
    };
  };

  netkit.clash = {
    enable = true;
    redirPort = 7892; # This must be the same with the one in your clash.yaml
  };
}
