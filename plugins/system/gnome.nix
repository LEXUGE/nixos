{ pkgs, config, lib, ... }:

with lib;

let cfg = config.icebox.static.system.gnome;
in {
  options.icebox.static.system.gnome.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable GNOME3 and GDM";
  };

  config = mkIf (cfg.enable) {
    icebox.static.lib.configs.system.bluetooth.service = null;
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome3.enable = true;
    };
    # Some of the GNOME Packages are unwanted
    programs.geary.enable = false;
    environment.gnome3.excludePackages =
      [ pkgs.gnome3.epiphany pkgs.gnome3.gnome-software ];
  };
}
