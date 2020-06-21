{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "yacd";
  version = "v0.1.22";

  src = fetchzip {
    url = "https://github.com/haishanh/yacd/archive/gh-pages.zip";
    sha256 = "05wrgzlc6m2n6y6aa276qk7c8d48rc4k6bvyayrgm3gj99zf5ybw";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src $out
  '';
}
