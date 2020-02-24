{ config, pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable fwupd service
  services.fwupd.enable = true;

  # Enable ThinkPad Throttled (Currently unavailable for X1C7)
  # services.throttled.enable = true;

  # Enable fprintd
  services.fprintd.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
