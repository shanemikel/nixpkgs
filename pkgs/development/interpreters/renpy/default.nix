{ stdenv, fetchurl, python, cython, pkgconfig, wrapPython
, pygame, SDL, libpng, ffmpeg, freetype, glew, mesa, fribidi, zlib
}:

stdenv.mkDerivation {
  name = "renpy-6.17.1";

  meta = {
    description = "Ren'Py Visual Novel Engine";
    homepage = "http://renpy.org/";
    license = "MIT";
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ iyzsong ];
  };

  src = fetchurl {
    url = "http://www.renpy.org/dl/6.17.1/renpy-6.17.1-source.tar.bz2";
    sha256 = "024v05yifs6c13chpg0azjpi6xk1srrhd1d0hcs946xbjvbbadpc";
  };

  buildInputs = [
    python cython pkgconfig wrapPython
    SDL libpng ffmpeg freetype glew mesa fribidi zlib pygame
  ];

  pythonPath = [ pygame ];

  RENPY_DEPS_INSTALL = stdenv.lib.concatStringsSep "::" (map (path: "${path}") [
    SDL libpng ffmpeg freetype glew mesa fribidi zlib
  ]);

  buildPhase = ''
    python module/setup.py build
  '';

  installPhase = ''
    mkdir -p $out/share/renpy
    cp -r renpy renpy.py $out/share/renpy
    python module/setup.py install --prefix=$out --install-lib=$out/share/renpy/module

    wrapPythonPrograms
    makeWrapper ${python}/bin/python $out/bin/renpy \
      --set PYTHONPATH $program_PYTHONPATH \
      --set RENPY_BASE $out/share/renpy \
      --add-flags "-O $out/share/renpy/renpy.py"
  '';

  NIX_CFLAGS_COMPILE = "-I${pygame}/include/${python.libPrefix}";
}
