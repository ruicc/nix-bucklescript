{ stdenv, fetchFromGitHub, ninja, nodejs, ocamlPackages }:
let
  ocaml =  import ./ocaml.nix {
    inherit stdenv fetchFromGitHub;
  };
  # oPkgs = ocamlPackages.overrideScope' (self: super: {
  #   inherit ocaml;
  #   ocamlbuild = ocaml;
  # });
in
stdenv.mkDerivation rec {
  name = "bucklescript-${version}";
  version = "5.0.6";
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "72c23b3378afe9cd8477e9a16fcae958039f9828"; # maybe 5.0.6
    sha256 = "015a7n04pliyy18z4ikzvcjm9qakrph4xhz9vlnbcksn7ynjjlbc";
  };
  BS_RELEASE_BUILD = "true";
  buildInputs = [ ocaml  ninja nodejs ]; # oPkgs.cppo oPkgs.camlp4
  buildPhase = ''
    mkdir -p $out
    cp -rf jscomp lib scripts vendor odoc_gen $out
    cp -r bsconfig.json package.json $out
    cd $out
    node ./scripts/ninja.js
    ninja -C jscomp -f env.ninja

    for name in $(find ${ocaml} -printf "%P\n");
    do
      if [ -d ${ocaml}/$name ]; then
        mkdir -p $out/vendor/ocaml/$name
      else
        ln -sf ${ocaml}/$name $out/vendor/ocaml/$name
      fi
    done

    # provideNinja
    ln -s ${ninja}/bin/ninja $out/lib/ninja.exe
    # provideCompiler
    ninja -C $out/lib
    # buildLibs
    cd $out/jscomp
    ninja -f release.ninja -t clean
    ninja -f release.ninja
    # install
    ln -s $out/jscomp/runtime $out/lib/ocaml
    ln -s $out/jscomp/others $out/lib/ocaml
    ln -s $out/jscomp/stdlib-402 $out/lib/ocaml
  '';
  installPhase = ''
    mkdir -p $out/bin
    ln -s $out/lib/bsb $out/bin/bsb
    ln -s $out/lib/bsc $out/bin/bsc
    ln -s $out/lib/bsrefmt $out/bin/bsrefmt
    # remove unnecessary binaries
    rm $out/lib/*.darwin
    rm $out/lib/*.win32
  '';
}
