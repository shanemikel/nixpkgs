{ stdenv, fetchurl, buildPythonApplication
, zip, ffmpeg, rtmpdump, atomicparsley, pandoc
# Pandoc is required to build the package's man page. Release tarballs contain a
# formatted man page already, though, it will still be installed. We keep the
# manpage argument in place in case someone wants to use this derivation to
# build a Git version of the tool that doesn't have the formatted man page
# included.
, generateManPage ? false
, ffmpegSupport ? true
, rtmpSupport ? true
, makeWrapper }:

with stdenv.lib;
buildPythonApplication rec {

  name = "youtube-dl-${version}";
  version = "2017.04.17";

  src = fetchurl {
    url = "https://yt-dl.org/downloads/${version}/${name}.tar.gz";
    sha256 = "0bihcjghrpj8skh216wwb7i2r990f6b7x63m8vdamq5bw317wvrj";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ zip ] ++ optional generateManPage pandoc;

  # Ensure ffmpeg is available in $PATH for post-processing & transcoding support.
  # rtmpdump is required to download files over RTMP
  # atomicparsley for embedding thumbnails
  postInstall = let
    packagesToBinPath =
    [ atomicparsley ]
    ++ optional ffmpegSupport ffmpeg
    ++ optional rtmpSupport rtmpdump;
  in ''
    wrapProgram $out/bin/youtube-dl --prefix PATH : "${makeBinPath packagesToBinPath}"
  '';

  # Requires network
  doCheck = false;

  meta = {
    homepage = http://rg3.github.io/youtube-dl/;
    repositories.git = https://github.com/rg3/youtube-dl.git;
    description = "Command-line tool to download videos from YouTube.com and other sites";
    longDescription = ''
      youtube-dl is a small, Python-based command-line program
      to download videos from YouTube.com and a few more sites.
      youtube-dl is released to the public domain, which means
      you can modify it, redistribute it or use it however you like.
    '';
    license = licenses.publicDomain;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ bluescreen303 phreedom AndersonTorres fuuzetsu fpletz ];
  };
}
