# This is a custom built simple-obfs package for NixOS. Revised from https://github.com/Ninlives/nixos-config

with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "smartdns";
  version = "29";
  src = fetchFromGitHub {
    owner = "pymumu";
    repo = "smartdns";
    rev = "Release${version}";
    sha256 = "06kgmahgma0ybhacqzj5sfazmhzs3p27a0sxik4xbbk3dyqn9ykj";
  };

  buildInputs = [ openssl ];
  nativeBuildInputs = [ ];

  preBuild = "cd src/";

  installPhase = ''
    install -Dm755 smartdns $out/bin/smartdns
     '';
}
