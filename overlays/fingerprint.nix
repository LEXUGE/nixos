self: super: {
  fprintd = (super.callPackage ../packages/fprintd.nix {
    libpam-wrapper = (super.callPackage ../packages/libpam-wrapper.nix { });
  });
  libfprint = (super.callPackage ../packages/libfprint.nix { });
}
