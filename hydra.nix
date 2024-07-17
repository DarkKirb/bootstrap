{nixpkgs ? <nixpkgs>}: let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "riscv64-linux"
  ];
  lib = (import nixpkgs {}).lib;
  filterDerivationsRecursive = attrs:
    lib.mapAttrs (_: v:
      if lib.isDerivation v
      then v
      else filterDerivationsRecursive v) (lib.filterAttrs (_: val: (
        lib.isDerivation val || lib.isAttrs val && val.recurseForDerivations or false
      ))
      attrs);
in
  lib.genAttrs systems (system: let
    pkgs = import ./. {
      buildSystem = system;
      inherit nixpkgs;
    };
  in
    filterDerivationsRecursive pkgs)
