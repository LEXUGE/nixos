# Device specific configuration for ThinkPad X1 Carbon 7th Gen (20R1)
{ config, pkgs, lib, ... }:

let
  cfg = config.local.devices.x1c7;
  inherit (config.local) share;
in lib.mkIf cfg.enable (lib.mkMerge [
  ({
    # Activate acpi_call module for TLP ThinkPad features
    boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    # Set hardware related attributes
    local.share.ramSize = 16384;
    local.share.battery = [ "BAT0" ];
    local.share.power = [ "AC" ];

    # Set DPi to 200% scale
    local.share.scale = 2;
    local.share.network-interface = [ "wlp0s20f3" ];

    # Update Intel CPU Microcode
    hardware.cpu.intel.updateMicrocode = true;

    # Enable Bluetuooth by default
    local.share.bluetooth.enable = lib.mkDefault true;

    # Enable TLP Power Management
    services.tlp = {
      enable = true;
      extraConfig = ''
        START_CHARGE_THRESH_BAT0=85
        STOP_CHARGE_THRESH_BAT0=90
      '';
    };
  })

  (lib.mkIf (cfg.bio-auth == "howdy") {
    # Howdy service configuration
    services = {
      howdy = {
        enable = true;
        device = "/dev/video2";
        certainty = 5;
        dark-threshold = 100;
      };
      ir-toggle.enable = true;
    };
  })

  (lib.mkIf (cfg.enable == "fprintd") {
    # Enable fprintd
    services.fprintd.enable = true;
  })

  (lib.mkIf (share.swapResumeOffset != null) {
    # Enable UPower to take action under critical situations. Only when hibernation is possible.
    services.upower = {
      enable = true;
      percentageCritical = 5;
      percentageAction = 3;
    };
  })
])
