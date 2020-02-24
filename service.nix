{ config, pkgs, ... }:

let unstable = import <unstable> { };
in {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable fwupd service
  services.fwupd = {
    enable = true;
    package = unstable.pkgs.fwupd;
  };

  # Enable ThinkPad Throttled (Currently unavailable for X1C7)
  # services.throttled.enable = true;

  # Enable fprintd
  services.fprintd = {
    enable = true;
    package = unstable.pkgs.fprintd;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
