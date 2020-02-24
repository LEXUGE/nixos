{ stdenv, fetchFromGitHub, cmake, openpam, python3 }:

stdenv.mkDerivation rec {
  version = "2016-05-06";
  pname = "libpam-wrapper";

  src = fetchFromGitHub {
    owner = "jhrozek";
    repo = "pam_wrapper";
    rev = "ff7ec1c5ea7ed2360cbc59bd58f9caae7c9fa53d";
    sha256 = "0hmhkj0cvar5g7aa8qhki5r0hcjjl31s769vxzkf66nkkv854afd";
  };

  nativeBuildInputs = [ cmake python3 ];

  buildInputs = [ openpam ];

  meta = with stdenv.lib; {
    description = "Wrapper for testing pam modules.";
    homepage = "https://github.com/jhrozek/pam_wrapper";
    license = licenses.gpl3;
    maintainers = [ maintainers.elyhaka ];
    platforms = platforms.linux;
  };
}
