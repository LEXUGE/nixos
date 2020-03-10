{ stdenv, python2, python2Packages, fetchurl, pam }:
let outPath = placeholder "out";
in stdenv.mkDerivation rec {
  pname = "pam-python";
  version = "1.0.7";
  src = fetchurl {
    url =
      "https://downloads.sourceforge.net/project/pam-python/pam-python-1.0.7-1/pam-python-1.0.7.tar.gz";
    sha256 = "01vylk8vmzsvxf0iwn2nizwkhdzk0vpyqh5m1rybh0sv6pz75kln";
  };
  buildInputs = [ python2 python2Packages.sphinx pam ];
  preBuild = ''
    patchShebangs .
    substituteInPlace src/Makefile --replace '-Werror' '-O -Werror=cpp'
  '';
  makeFlags = [ "PREFIX=${outPath}" "LIBDIR=${outPath}/lib/security" ];
}
