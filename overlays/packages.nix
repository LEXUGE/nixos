self: super: {
  fprintd = (super.callPackage ../packages/fprintd.nix {
    libpam-wrapper = (super.callPackage ../packages/libpam-wrapper.nix { });
  });
  libfprint = (super.callPackage ../packages/libfprint.nix { });
  howdy = (super.callPackage ../packages/howdy.nix { });
  pam_python = (super.callPackage ../packages/pam_python.nix { });
  ir_toggle = (super.callPackage ../packages/ir_toggle.nix { });
  clash = (super.callPackage ../packages/clash.nix { });

  tdesktop = super.tdesktop.overrideAttrs (oldAttrs: rec {
    version = "2.0.1";
    src = super.fetchurl {
      url =
        "https://github.com/telegramdesktop/tdesktop/releases/download/v${version}/tdesktop-${version}-full.tar.gz";
      sha256 = "0g3jw4can9gmp48s3b8s1w8n9xi54i142y74fszxf9jyq5drzlff";
    };
  });
}
