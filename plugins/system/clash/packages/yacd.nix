{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "yacd";

  src = builtins.fetchGit {
    url = "https://github.com/haishanh/yacd.git";
    ref = "gh-pages";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r $src $out
  '';
}
