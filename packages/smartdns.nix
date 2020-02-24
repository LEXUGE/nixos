with import <nixpkgs> { };

stdenv.mkDerivation rec {
  pname = "smartdns";
  version = "29";
  src = fetchFromGitHub {
    owner = "pymumu";
    repo = pname;
    rev = "Release${version}";
    sha256 = "06kgmahgma0ybhacqzj5sfazmhzs3p27a0sxik4xbbk3dyqn9ykj";
  };

  buildInputs = [ openssl ];

  sourceRoot = "source/src";

  installPhase = "install -Dm755 smartdns $out/bin/smartdns";

  meta = with stdenv.lib; {
    description =
      " A local DNS server to obtain the fastest website IP for the best Internet experience";
    longDescription = ''
      SmartDNS is a local DNS server. SmartDNS accepts DNS query requests from local clients, obtains DNS query results from multiple upstream DNS servers, and returns the fastest access results to clients.
      Avoiding DNS pollution and improving network access speed, supports high-performance ad filtering.
      Unlike dnsmasq's all-servers, smartdns returns the fastest access resolution.
    '';
    homepage = "https://github.com/pymumu/smartdns";
    maintainers = [ maintainers.lexuge ];
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
