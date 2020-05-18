{ appimageTools, fetchurl }:

let
  pname = "desktopeditors";
  version = "5.5.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url =
      "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/ONLYOFFICE-DesktopEditors-${version}/DesktopEditors-x86_64.AppImage";
    sha256 = "135ag43r9njphsvfvqczq1v36f67j793idaj7pn4nll169k41i6j";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;
  extraPkgs = pkgs: with pkgs; [ libpulseaudio ];
  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/onlyoffice-desktopeditors.desktop $out/share/applications/onlyoffice-desktopeditors.desktop
    install -m 444 -D ${appimageContents}/asc-de.png $out/share/icons/hicolor/256x256/apps/asc-de.png
  '';
}
