{ config, pkgs, lib, ... }:

let cfg = config.meta.system;
in {
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
}
