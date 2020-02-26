with import <nixpkgs> { };

stdenv.mkDerivation rec {
  pname = "smartdns";
  version = "30";

  src = fetchFromGitHub {
    owner = "pymumu";
    repo = pname;
    rev = "Release${version}";
    sha256 = "1zj1ajvdnpmdal87j7fyn0xdd0ydjii1nvgwgacv2j311b6fdrk7";
  };

  patches = [
    # TODO: A patch is needed by now since the upstream doesn't follow the FHS guideline. It should not be the case in the future.
    (fetchpatch {
      url =
        "https://git.archlinux.org/svntogit/community.git/plain/trunk/systemd.patch?h=packages/smartdns&id=c15e81742c93e24c47de59a956f1d0d0f7156f0a";
      name = "systemd.nix";
      sha256 = "0jxzsgxz6y1a4mvwk6d5carxv4nxsswpfs1a6jkplzy2gr0g8281";
    })
  ];

  patchFlags = [ "-p1" "systemd/smartdns.service" ];

  postPatch = ''
    substituteInPlace systemd/smartdns.service --replace /usr/bin/smartdns $out/bin/smartdns
  '';

  buildInputs = [ openssl ];

  makeFlags = [ "-C" "src" ];

  # TODO: Manual installation is needed by now due to upstream issue.
  installPhase = ''
    runHook preInstall
    install -Dm644 systemd/smartdns.service $out/etc/systemd/system/smartdns.service
    install -Dm644 etc/default/smartdns $out/etc/default/smartdns
    install -Dm755 src/smartdns $out/bin/smartdns
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description =
      "A local DNS server to obtain the fastest website IP for the best Internet experience";
    longDescription = ''
      SmartDNS is a local DNS server. SmartDNS accepts DNS query requests from local clients, obtains DNS query results from multiple upstream DNS servers, and returns the fastest access results to clients.
      Avoiding DNS pollution and improving network access speed, supports high-performance ad filtering.
      Unlike dnsmasq's all-servers, smartdns returns the fastest access resolution.
    '';
    homepage = "https://github.com/pymumu/smartdns";
    maintainers = [ maintainers.lexuge ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
