{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "maxmind-geoip";
  version = "20200409";

  src = fetchurl {
    url =
      "https://github.com/Dreamacro/${pname}/releases/download/${version}/Country.mmdb";
    sha256 = "08iqqglc7q7km0ga5jzb4b5cc5x170533qmkhciy70k2zg6gwr98";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/Country.mmdb
  '';
}
