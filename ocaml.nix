{ stdenv, fetchFromGitHub, }:
let
  rev = "4.0.18";
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = rev;
    sha256 = "0ql5ivf0bjmb8495ak2lx9wis3yll64irn8rh7nbn4rrpfvr4vfb";
  };
in
stdenv.mkDerivation rec {
  version = "4.02.3";
  name = "ocaml-${version}+bs-${rev}";
  inherit src;
  # this option is provided by scripts/buildocaml.sh -no-ocamlbuild -no-shared-libs -no-ocamldoc
  configurePhase = ''
    cd vendor/ocaml
    ./configure -prefix $out -no-curses -no-graph -no-pthread -no-debugger
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
