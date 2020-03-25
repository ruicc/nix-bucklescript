let
  source = import ./nix/sources.nix;
  nixpkgs = import source.nixpkgs {};
  inherit (import source.niv {}) niv;
in
{ nixpkgs ? nixpkgs }:
{
    bucklescript_4 = import ./4/bucklescript.nix;
    bucklescript_5 = import ./5/default.nix;
    bucklescript_6 = import ./6/bucklescript.nix;
}
