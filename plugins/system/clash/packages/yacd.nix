{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "yacd";
  version = "v0.1.21";

  src = fetchzip {
    url = "https://github.com/haishanh/yacd/archive/gh-pages.zip";
    sha256 = "1z15xywyax0q2fidvk4n1ixsfb9zsd7ybzxwzsj494ddxikj1216";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src $out
  '';
}
