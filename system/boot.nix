{ config, pkgs, ... }:

{
  # Use Keyfile to unlock the root partition to avoid keying in twice.
  # Allow fstrim to work on it.
  boot.initrd.luks.devices."cryptroot" = {
    keyFile = "/keyfile.bin";
    allowDiscards = true;
  };

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
