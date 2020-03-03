{ config, pkgs, ... }:

{
  # Use GRUB with encrypted /boot under EFI env.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Activate acpi_call module for TLP features
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
}
