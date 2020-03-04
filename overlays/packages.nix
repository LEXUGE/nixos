self: super:
let
  unstable = import <unstable> { };
  unstable-nonfree = import <unstable> { config.allowUnfree = true; };
in {
  fprintd = (super.callPackage ../packages/fprintd.nix {
    libpam-wrapper = (super.callPackage ../packages/libpam-wrapper.nix { });
  });
  libfprint = (super.callPackage ../packages/libfprint.nix { });
  smartdns = (super.callPackage ../packages/smartdns.nix { });
  simple-obfs = (super.callPackage ../packages/simple-obfs.nix { });
  fwupd = unstable.fwupd;
  minecraft = unstable-nonfree.minecraft;
}
