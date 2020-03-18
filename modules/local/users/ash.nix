# This is the module is dedicated to configuration options of user ash's profile.

{ config, lib, ... }:

let inherit (config.local) share;
in {
  options.local.users.ash = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether to enable user <literal>ash</literal>.";
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      description =
        "Extra packages to install for user <literal>ash</literal>.";
    };
    battery = mkOption {
      type = types.enum share.battery;
      description =
        "Battery name under <literal>/sys/class/power_supply/</literal> used by polybar <literal>battery</literal> module. Choose one in <option>options.local.battery</option>";
    };

    power = mkOption {
      type = types.enum share.power;
      description =
        "AC power adapter name under <literal>/sys/class/power_supply/</literal> used by polybar <literal>battery</literal> module. Choose one in <option>options.local.power</option>";
    };

    network-interface = mkOption {
      type = types.enum share.network-interface;
      description = "Network interface name to monitor on bar";
    };
  };
}
