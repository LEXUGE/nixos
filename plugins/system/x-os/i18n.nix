{ config, pkgs, lib, ... }:

with lib;

let cfg = config.icebox.static.system.x-os;
in {
  options.icebox.static.system.x-os.ibus-engines = mkOption {
    type = types.listOf types.package;
    default = [ ];
    example = literalExample "with pkgs.ibus-engines; [ mozc hangul ]";
    description = "List of ibus engines to apply";
  };

  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Asia/Shanghai";

    # Select internationalisation properties.
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    i18n = {
      defaultLocale = "en_US.UTF-8";
      inputMethod = {
        enabled = "ibus";
        ibus.engines = cfg.ibus-engines;
      };
    };
  };
}
