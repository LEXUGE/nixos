{ config, pkgs, ... }:

{
  # Use Keyfile to unlock the root partition to avoid keying in twice.
  boot.initrd.luks.devices."cryptroot".keyFile = "/keyfile.bin";

  # Use GRUB with encrypted /boot under EFI env.
  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
      extraInitrd = "/boot/initrd.keys.gz"; # Add LUKS key to the initrd
    };
  };
}
