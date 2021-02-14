# Device specific configuration for ThinkPad X1 Carbon 7th Gen (20R1)
{ config, pkgs, lib, ... }:
with lib; {
  config = {
    # Set device hostname
    x-os.hostname = "x1c7";

    # Activate acpi_call module for TLP ThinkPad features
    boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    netkit.xmm7360 = {
      enable = true;
      autoStart = true;
      config = {
        apn = "3gnet";
        nodefaultroute = false;
        noresolv = true;
      };
      package = pkgs.netkit.xmm7360-pci_latest;
    };

    # Set hardware related attributes
    std.interface = {
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
      settings = {
        START_CHARGE_THRESH_BAT0 = 85;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };

    # Enable fprintd
    services.fprintd.enable = true;
  };
}
