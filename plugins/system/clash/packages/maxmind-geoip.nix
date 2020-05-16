{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "maxmind-geoip";
  version = "20200506";

  src = fetchurl {
    url =
      "https://github.com/Dreamacro/${pname}/releases/download/${version}/Country.mmdb";
    sha256 = "0k4zczski4lmr18n6cmv03a9wkkb3f5zi82qaz8pjc9xncdqd3qh";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/Country.mmdb
  '';
}
