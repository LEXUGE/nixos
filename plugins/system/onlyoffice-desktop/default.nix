{ pkgs, lib, config, ... }:

with lib;

let cfg = config.icebox.static.system.onlyoffice-desktop;
in {
  options.icebox.static.system.onlyoffice-desktop.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Add ONLYOFFICE desktop office suite to overlay";
  };

  config = mkIf (cfg.enable) {
    icebox.overlays = [
      (self: super: {
        onlyoffice-desktop =
          (super.callPackage ./packages/desktopeditors.nix { });
      })
    ];
  };
}
