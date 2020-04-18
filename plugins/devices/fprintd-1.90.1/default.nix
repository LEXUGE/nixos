{ config, lib, ... }:
with lib;

let cfg = config.icebox.static.devices.fprintd-1-90-1;
in {
  options.icebox.static.devices.fprintd-1-90-1 = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    icebox.overlays = [
      (self: super: {
        fprintd = (super.callPackage ./packages/fprintd.nix {
          libpam-wrapper =
            (super.callPackage ./packages/libpam-wrapper.nix { });
        });
        libfprint = (super.callPackage ./packages/libfprint.nix { });
      })
    ];
  };
}
