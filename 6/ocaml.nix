{ stdenv, fetchFromGitHub, }:
let
  rev = "fbc417a71506f843ca6c0061c77ded016a72e577";
in
stdenv.mkDerivation rec {
  version = "4.06.1";
  name = "ocaml-${version}+bs-${rev}";
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "ocaml";
    inherit rev;
    sha256 = "0lyiygmb2b3n8j6x9d91hc4ihmaszpspispvjcv2v5yxiry0xz09";
  };
  configurePhase = ''
    ./configure -prefix $out -no-ocamlbuild  -no-curses -no-graph -no-pthread -no-debugger
  '';
  buildPhase = ''
    make -j9 world.opt
  '';
  installPhase = ''
    make install
  '';

  meta = with stdenv.lib; {
    branch = "4.06";
    platforms = with platforms; linux ++ darwin;
  };
}
