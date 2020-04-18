# Device specific configuration for ThinkPad X1 Carbon 7th Gen (20R1)
{ config, pkgs, lib, ... }:

let cfg = config.icebox.static.devices.x1c7;
in {
  options.icebox.static.devices.x1c7 = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description =
        "Whether to enable ThinkPad X1 Carbon 7th Gen device profile.";
    };

    bio-auth = mkOption {
      type = with types; nullOr (enum [ "howdy" "fprintd" ]);
      default = null;
      example = "howdy";
      description = "Biometric authentication method.";
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      ({
        # Activate acpi_call module for TLP ThinkPad features
        boot.extraModulePackages = with config.boot.kernelPackages;
          [ acpi_call ];

        # Set hardware related attributes
        icebox.static.lib.configs = {
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

        # Enable TLP Power Management
        services.tlp = {
          enable = true;
          extraConfig = ''
            START_CHARGE_THRESH_BAT0=85
            STOP_CHARGE_THRESH_BAT0=90
          '';
        };
      })

      (mkIf (cfg.bio-auth == "howdy") {
        # Howdy service configuration
        icebox.static.devices = {
          howdy = {
            enable = true;
            device = "/dev/video2";
            certainty = 5;
            dark-threshold = 100;
          };
          ir-toggle.enable = true;
        };
      })

      (mkIf (cfg.bio-auth == "fprintd") {
        # Enable fprintd
        icebox.static.devices.fprintd-1-90-1.enable = true;
        services.fprintd.enable = true;
      })

      (mkIf
        (config.icebox.static.lib.configs.devices.swapResumeOffset != null) {
          # Enable UPower to take action under critical situations. Only when hibernation is possible.
          services.upower = {
            enable = true;
            percentageCritical = 5;
            percentageAction = 3;
          };
        })
    ]);
}
