# This is a module that enables us to share values across different parts (system, user, device)

{ lib, ... }:

{
  options.local.share = with lib; {
    scale = mkOption {
      type = types.int;
      default = 1;
      description =
        "The global scale factor. Defined by device profile usually.";
    };

    battery = mkOption {
      type = with types; listOf str;
      visible = false;
      default = [ "BAT0" ];
      description =
        "All the battery filenames under <literal>/sys/class/power_supply/</literal>.";
    };

    power = mkOption {
      type = with types; listOf str;
      visible = false;
      default = [ "AC" ];
      description =
        "All the AC Power filenames under <literal>/sys/class/power_supply/</literal>.";
    };

    network-interface = mkOption {
      type = with types; listOf str;
      visible = false;
      default = [ "wlan0" ];
      description = "All the network interface name.";
    };

    bluetooth.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable bluetooth.";
    };

    bluetooth.service = mkOption {
      type = with types; nullOr (enum [ "blueman" ]);
      default = null;
      description = "Global flag of whether enable bluetooth.";
    };
  };
}
