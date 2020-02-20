# This is a custom built ShadowsocksR package for NixOS. Revised from https://github.com/Ninlives/nixos-config
# Package is meant to use with `callPackage` but not build standalone.

{ stdenv, fetchgit, libsodium, libev, pcre,
  asciidoc, xmlto, docbook_xml_dtd_45, docbook_xsl, zlib,
  openssl, udns, autoconf, automake, libtool, patchelf }:

stdenv.mkDerivation {
  name = "shadowsocks";
  src = fetchgit {
    url    = "https://github.com/shadowsocksrr/shadowsocksr-libev.git";
    rev    = "ed6c9eb12530a7ecbdf3f5801fe59b177fe74779";
    sha256 = "1njd6m8afi2cnwi219yl6y5ypgsy8n99r825rp75i2qfx823rdg6";
  };

  buildInputs = [ libsodium libev pcre openssl udns ];
  nativeBuildInputs = [ 
    autoconf automake libtool 
    asciidoc xmlto docbook_xsl 
    docbook_xml_dtd_45 zlib patchelf
  ];


  preConfigure = ''
    ./autogen.sh
  '';

  preFixup = ''
    for executable in $out/bin/ss-local $out/bin/ss-redir; do
      patchelf --set-rpath $out/lib:$(patchelf --print-rpath "$executable") "$executable"
    done
  '';

  dontStrip = true;
}
