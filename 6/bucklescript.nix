{ stdenv, fetchFromGitHub, ninja, nodejs }:
let
  version = "6.2.0";
  ocaml =  import ./ocaml.nix {
    inherit stdenv fetchFromGitHub;
  };
in
stdenv.mkDerivation {
  name = "bucklescript-${version}";
  inherit ocaml version;
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "6.2.0";
    sha256 = "1v3fa6sjs4mj2mb1f7y2xl6v3j5fikc04ssb7z908q91dkzwy0mr";
  };
  BS_RELEASE_BUILD = "true";
  buildInputs = [ ocaml ninja nodejs ];
  buildPhase = ''
    mkdir -p $out 
    cp -rf jscomp lib scripts vendor odoc_gen $out
    cp -r bsconfig.json package.json $out
    # this is for getVersionPrefix() in buildocaml.js
    ln -s ${ocaml.src}/ $out/ocaml
    # remove unnecessary binaries. if got wrong by this, the build is wrong
    rm $out/lib/*.linux
    rm $out/lib/*.darwin
    rm $out/lib/*.win32
    rm $out/vendor/*.gz

    # this also do `rm $out/vendor/ninja/snapshot/ninja.*`
    for ext in linux darwin win32;
    do
      ln -sf ${ninja}/bin/ninja $out/vendor/ninja/snapshot/ninja.$ext
    done

    mkdir -p $out/native/
    ln -s ${ocaml}/ $out/native/${ocaml.version}

    node $out/scripts/ninja.js config
    node $out/scripts/ninja.js build
  '';
  installPhase = ''
    sed -i 's:1.9.0.git:1.9.0:' $out/scripts/install.js
    node $out/scripts/install.js

    mkdir -p $out/bin
    ln -s $out/lib/bsb $out/bin/bsb
    ln -s $out/lib/bsc $out/bin/bsc
    ln -s $out/lib/bsrefmt $out/bin/bsrefmt
  '';
}
