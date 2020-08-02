{ config, pkgs, lib, ... }:

let
  inherit (config.std) devices system;
  cfg = config.x-os;
in with lib; {
  options.x-os.noBoot = mkOption {
    type = types.bool;
    default = false;
    description =
      "Include no boot-related configuration. Useful in building ISO.";
  };
  config = mkIf (cfg.enable && !cfg.noBoot) (mkMerge [
    ({
      # Enable plymouth for better experience of booting
      boot.plymouth.enable = true;

      # Use Keyfile to unlock the root partition to avoid keying in twice.
      # Allow fstrim to work on it.
      boot.initrd = {
        secrets = { "/keyfile.bin" = (system.dirs.secrets + /keyfile.bin); };
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
