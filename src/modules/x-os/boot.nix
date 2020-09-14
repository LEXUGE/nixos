{ config, pkgs, lib, ... }:

let
  inherit (config.std.interface) devices system;
  cfg = config.x-os;
in with lib; {
  options.x-os.enableBoot = mkOption {
    type = types.bool;
    default = true;
    description = "Include boot-related configuration.";
  };
  config = mkIf (cfg.enable && cfg.enableBoot) (mkMerge [
    ({
      # Enable plymouth for better experience of booting
      boot.plymouth.enable = true;

      # Use Keyfile to unlock the root partition to avoid keying in twice.
      # Allow fstrim to work on it.
      boot.initrd = {
        secrets = { "/keyfile.bin" = system.dirs.secrets.keyfile; };
        luks.devices."cryptroot" = {
          keyFile = "/keyfile.bin";
          allowDiscards = true;
          fallbackToPassword = true;
        };
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
        };
      };
    })

    # Resume kernel parameter
    # If there is no swapResumeOffset defined, then we simply skip it.
    (mkIf (devices.swapResumeOffset != null) {
      boot.resumeDevice = "/dev/mapper/cryptroot";
      boot.kernelParams =
        [ "resume_offset=${toString devices.swapResumeOffset}" ];
    })
  ]);
}
