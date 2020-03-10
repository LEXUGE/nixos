{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "chicony-ir-toggle";

  src = fetchFromGitHub {
    owner = "PetePriority";
    repo = name;
    rev = "5758112ae7f502035d48f24123347ba37cdbdb34";
    sha256 = "1ihxkvhjbryhw5xjnw5a36f5w8nn4lnf07dzmzi6jzrn5ax131hw";
  };

  nativeBuildInputs = [ cmake ];
  preInstall = ''
    substituteInPlace ../CMakeLists.txt --replace /lib $out/lib
  '';
}
