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

  patches = [
    (fetchpatch {
      url =
        "https://git.archlinux.org/svntogit/community.git/plain/trunk/systemd.patch?h=packages/smartdns";
      sha256 = "0jxzsgxz6y1a4mvwk6d5carxv4nxsswpfs1a6jkplzy2gr0g8281";
    })
  ];

  prePatch = "chmod -R +w ../systemd";

  patchFlags = [ "-p1" "../systemd/smartdns.service" ];

  postPatch =
    "substituteInPlace ../systemd/smartdns.service --replace /usr/bin/smartdns $out/bin/smartdns";

  sourceRoot = "source/src";

  installPhase = ''
    runHook preInstall
    install -Dm644 ../systemd/smartdns.service $out/etc/systemd/system/smartdns.service
    install -Dm644 ../etc/default/smartdns $out/etc/default/smartdns
    install -Dm755 smartdns $out/bin/smartdns
    runHook postInstall
  '';

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
    platforms = platforms.linux;
  };
}
