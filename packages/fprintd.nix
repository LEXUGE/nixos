{ stdenv, fetchFromGitLab, fetchpatch, pkgconfig, meson, ninja, intltool
, libpam-wrapper, cairo, gtk-doc, glib, dbus-glib, polkit, nss, pam, systemd
, libfprint, python37Packages }:

stdenv.mkDerivation rec {
  pname = "fprintd";
  version = "1.90.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "libfprint";
    repo = "fprintd";
    rev = "b90b21f26b23094da16be2fa7ec4862e865b32dc";
    sha256 = "0gj2f48zs49l2zrs49qhqy99mdznpvw6vkqlxvq32amr15pqdpsd";
  };

  pythonPath = with python37Packages; [
    python-dbusmock
    dbus-python
    pygobject3
    pycairo
    libpam-wrapper
    gtk-doc
  ];

  nativeBuildInputs =
    [ pkgconfig meson ninja intltool libpam-wrapper pythonPath ];

  buildInputs = [ glib dbus-glib polkit nss pam systemd libfprint ];

  patches = [ ./fprintd.patch ];

  preConfigure = ''
    substituteInPlace meson.build --replace \
      "polkit_gobject_dep.get_pkgconfig_variable('policydir')" \
      "'$out/share/polkit-1/actions'"

    substituteInPlace meson.build --replace \
      "dbus_dep.get_pkgconfig_variable('interfaces_dir')" \
      "'$out/share/dbus-1/interfaces'"

    substituteInPlace meson.build --replace \
      "dbus_data_dir / 'dbus-1/system.d'" \
      "'$out/share/dbus-1/system.d'"
  '';

  mesonFlags = [
    "-Dpam_modules_dir=${placeholder "out"}/lib/security"
    "-Dsysconfdir=${placeholder "out"}/etc"
    "-Ddbus_service_dir=${placeholder "out"}/share/dbus-1/system-services"
    "-Dpolicydir=${placeholder "out"}/share/polkit-1/actions"
    "-Dsystemd_system_unit_dir=${placeholder "out"}/lib/systemd/system"
  ];

  meta = with stdenv.lib; {
    homepage = "https://fprint.freedesktop.org/";
    description =
      "D-Bus daemon that offers libfprint functionality over the D-Bus interprocess communication bus";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar elyhaka ];
  };
}
