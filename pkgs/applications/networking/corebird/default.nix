{ stdenv, fetchFromGitHub, gtk3, json_glib, sqlite, libsoup, gettext, vala_0_32
, automake, autoconf, libtool, pkgconfig, gnome3, gst_all_1, wrapGAppsHook
, glib_networking }:

stdenv.mkDerivation rec {
  version = "1.4.2";
  name = "corebird-${version}";

  src = fetchFromGitHub {
    owner = "baedert";
    repo = "corebird";
    rev = version;
    sha256 = "0s28q9c7p4p4jyhb1g6gdwdphlf6yhi6yg4yn8bkd0gmyf9acakb";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  nativeBuildInputs = [ automake autoconf libtool pkgconfig wrapGAppsHook ];

  buildInputs = [
    gtk3 json_glib sqlite libsoup gettext vala_0_32 gnome3.rest gnome3.dconf gnome3.gspell glib_networking
  ] ++ (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav ]);

  meta = {
    description = "Native Gtk+ Twitter client for the Linux desktop";
    longDescription = "Corebird is a modern, easy and fun Twitter client.";
    homepage = http://corebird.baedert.org;
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.jonafato ];
  };
}
