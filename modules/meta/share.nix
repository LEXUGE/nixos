# This is a module that enables us to share values across different parts (system, user, device)

{ lib, ... }:

{
  options.meta.share = with lib; {
    scale = mkOption {
      type = types.int;
      default = 1;
      description = "The global scale factor. Defined by device profile.";
    };

    battery = mkOption {
      type = with types; listOf str;
      default = [ "BAT0" ];
      description =
        "All the battery filenames under <literal>/sys/class/power_supply/</literal>.";
    };

    power = mkOption {
      type = with types; listOf str;
      default = [ "AC" ];
      description =
        "All the AC Power filenames under <literal>/sys/class/power_supply/</literal>.";
    };

    network-interface = mkOption {
      type = with types; listOf str;
      default = [ "wlan0" ];
      description = "All the network interface name.";
    };
  };
}
