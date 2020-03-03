{ stdenv, fetchgit, openssl, libev, autoconf, automake, libtool, asciidoc, xmlto
, docbook_xsl, docbook_xml_dtd_45, zlib }:

stdenv.mkDerivation {
  name = "simple-obfs";
  src = fetchgit {
    url = "https://github.com/shadowsocks/simple-obfs.git";
    rev = "486bebd9208539058e57e23a12f23103016e09b4";
    sha256 = "1mwpy06b00zr5z9wh66vlvg06yadms84kzkjylzs7njmrxwm29bv";
  };

  buildInputs = [ libev openssl ];
  nativeBuildInputs = [
    autoconf
    automake
    libtool
    asciidoc
    xmlto
    docbook_xsl
    docbook_xml_dtd_45
    zlib
  ];

  preConfigure = ''
    ./autogen.sh
  '';
}
