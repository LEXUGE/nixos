{ config, lib, ... }:
with lib;

let cfg = config.share;
in {
  options.share = {
    scale = mkOption {
      type = types.int;
      default = 1;
      description =
        "The global scale factor that could be used across different parts (system, user, device). Defined by device.";
    };

    battery = mkOption {
      type = types.str;
      default = "BAT0";
      description =
        "Battery file under <literal>/sys/class/power_supply/</literal>.";
    };

    power = mkOption {
      type = types.str;
      default = "AC";
      description =
        "AC Power file under <literal>/sys/class/power_supply/</literal>.";
    };

  };
}
