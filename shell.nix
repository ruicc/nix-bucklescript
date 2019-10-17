with (import <nixpkgs> {});

let
    my-bucklescript = callPackage ./bucklescript.nix {};
    my-ocaml =  callPackage ./ocaml.nix {};

in

stdenv.mkDerivation {

  name = "my-bs";

  buildInputs = [
    my-bucklescript
    my-ocaml
    nodejs
    yarn
  ];
}
