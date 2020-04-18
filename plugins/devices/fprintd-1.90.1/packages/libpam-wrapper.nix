{ stdenv, fetchFromGitLab, cmake, openpam, python3 }:

stdenv.mkDerivation rec {
  version = "2020-02-03";
  pname = "libpam-wrapper";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "hadess1";
    repo = "pam_wrapper";
    rev = "0697da3592fdfe45a02123e98b47c0a37c32f15c";
    sha256 = "1jlxjyv9qqaqz948p4jnlrxv1w7kvbzwkyh58r63cg8hwan8h61d";
  };

  nativeBuildInputs = [ cmake python3 ];

  buildInputs = [ openpam ];

  cmakeFlags = [ "-DMAN_INSTALL_DIR=$out/share/man/man1" ];

  meta = with stdenv.lib; {
    description = "Wrapper for testing pam modules.";
    homepage = "https://github.com/jhrozek/pam_wrapper";
    license = licenses.gpl3;
    maintainers = [ maintainers.elyhaka ];
    platforms = platforms.linux;
  };
}
