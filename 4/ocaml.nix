{ stdenv, fetchFromGitHub, }:
let
  rev = "4.0.18";
  src = import ./src.nix { inherit fetchFromGitHub; };
in
stdenv.mkDerivation rec {
  version = "4.02.3";
  name = "ocaml-${version}+bs-${rev}";
  inherit src;
  configurePhase = ''
    cd vendor/ocaml
    ./configure -prefix $out
  '';
  buildPhase = ''
    make -j9 world.opt
  '';
  installPhase = ''
    make install
  '';

  meta = with stdenv.lib; {
    branch = "4.02";
    platforms = with platforms; linux ++ darwin;
  };
}
