self: super: {
  fprintd = (super.callPackage ../packages/fprintd.nix {
    libpam-wrapper = (super.callPackage ../packages/libpam-wrapper.nix { });
  });
  libfprint = (super.callPackage ../packages/libfprint.nix { });
  howdy = (super.callPackage ../packages/howdy.nix { });
  pam_python = (super.callPackage ../packages/pam_python.nix { });
  ir_toggle = (super.callPackage ../packages/ir_toggle.nix { });
  simple-obfs = (super.callPackage ../packages/simple-obfs.nix { });
  tdesktop = super.tdesktop.overrideAttrs (oldAttrs: rec {
    version = "2.0.0";
    src = super.fetchurl {
      url =
        "https://github.com/telegramdesktop/tdesktop/releases/download/v${version}/tdesktop-${version}-full.tar.gz";
      sha256 = "1ayyrb1z1hbmglshc4qif2zs2vysfj9c97wxkk00ll9d79w50hqx";
    };
  });
}
