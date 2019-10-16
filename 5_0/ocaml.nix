{ stdenv, fetchFromGitHub, }:
let 
  rev = "00d25c5e0dbec2bfe223d0354b239defab97878b" ;
in
stdenv.mkDerivation rec {
  version = "4.02.3";
  name = "ocaml-${version}+bs-${rev}";
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "ocaml";
    rev = rev;
    sha256 = "03m71y5d5pl2gpgk3myc98lrkhs607l1cyp9lidc62pxfxyg0dd5";
  };
  configurePhase = ''
    ./configure -prefix $out -no-ocamlbuild  -no-curses -no-graph -no-pthread -no-debugger && make clean
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
