# Device specific configuration for ThinkPad X1 Carbon 7th Gen (20R1)
{ config, pkgs, lib, ... }:
with lib; {
  config = mkMerge [
    ({
      # Set device hostname
      x-os.hostname = "x1c7";

      # Activate acpi_call module for TLP ThinkPad features
      boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

      # Set hardware related attributes
      std = {
        devices = {
          power = [ "AC" ];
          battery = [ "BAT0" ];
          ramSize = 16384;
          network-interface = [ "wlp0s20f3" ];
        };
        system = {
          # Set DPi to 200% scale
          scale = 2;
          # Enable Bluetuooth by default
          bluetooth.enable = mkDefault true;
        };
      };

      # Update Intel CPU Microcode
      hardware.cpu.intel.updateMicrocode = true;

      # Intel UHD 620 Hardware Acceleration
      hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          intel-media-driver # only available starting nixos-19.03 or the current nixos-unstable
        ];
      };

      # Enable TLP Power Management
      services.tlp = {
        enable = true;
        extraConfig = ''
          START_CHARGE_THRESH_BAT0=85
          STOP_CHARGE_THRESH_BAT0=90
        '';
      };

      # Enable fprintd
      services.fprintd.enable = true;
    })

    (mkIf (config.std.devices.swapResumeOffset != null) {
      # Enable UPower to take action under critical situations. Only when hibernation is possible.
      services.upower = {
        enable = true;
        percentageCritical = 5;
        percentageAction = 3;
      };
    })
  ];
}
