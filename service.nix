{ config, pkgs, ... }:

let unstable = import <unstable> { };
in {
  # Disable fwupd module to opt in unstbale module of fwupd
  # disabledModules = [ "services/hardware/fwupd.nix" ];
  # imports = [
  #   <unstable/nixos/modules/services/hardware/fwupd.nix>
  # ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Configuration to facilitate bluetooth headphones.
  hardware.pulseaudio = {
    enable = true;

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.enable = true;

  # Enable fwupd service
  services.fwupd = {
    # package = unstable.pkgs.fwupd;
    enable = true;
  };

  # Enable fprintd
  services.fprintd.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
