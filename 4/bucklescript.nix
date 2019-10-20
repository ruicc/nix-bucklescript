{ stdenv, fetchFromGitHub, ninja, nodejs, ocamlPackages }:
let
  version = "4.0.18";
  src = import ./src.nix { inherit fetchFromGitHub; };
  ocaml =  import ./ocaml.nix {
    inherit stdenv fetchFromGitHub;
  };
  oPkgs = ocamlPackages.overrideScope' (self: super: {
    inherit ocaml;
    ocamlbuild = ocaml;
  });
in
stdenv.mkDerivation {
  name = "bucklescript-${version}";
  version = version;
  inherit src ocaml;
  BS_RELEASE_BUILD = "true";
  buildInputs = [ ocaml oPkgs.cppo oPkgs.camlp4 ninja nodejs ];
  buildPhase = ''
    mkdir -p $out 
    cp -rf jscomp lib scripts vendor odoc_gen $out
    cp -r bsconfig.json package.json $out
    for name in $(find ${ocaml} -printf "%P\n");
    do
      if [ -d ${ocaml}/$name ]; then
        mkdir -p $out/vendor/ocaml/$name
      else
        ln -sf ${ocaml}/$name $out/vendor/ocaml/$name
      fi
    done

    # bug patch
    sed -i 's/..\/vendor\/ocaml\/ocamlopt.opt/..\/vendor\/ocaml\/bin\/ocamlopt.opt/' $out/jscomp/snapshot.ninja

    # build
    ninja -C $out/jscomp

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
