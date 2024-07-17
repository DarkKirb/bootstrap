{
  # System the build runs on
  buildSystem ? builtins.currentSystem,
  # System to generate binaries for
  hostSystem ? buildSystem,
  # for legacy compilers, this is the system a compiler compiles binaries to.
  targetSystem ? hostSystem,
  # bootstrap system, used to bootstrap certain binaries from
  bootstrapSystem ? (
    if buildSystem != "i686-linux" && buildSystem != "x86_64-linux" && buildSystem != "aarch64-linux"
    then "x86_64-linux"
    else buildSystem
  ),
  overlays ? [],
  nixpkgs ? <nixpkgs>,
}: let
  lib = (import nixpkgs {}).lib;
in
  lib.makeScope lib.callPackageWith (pkgs: {
    inherit lib;
    bootstrapBusybox =
      (import nixpkgs {
        system = bootstrapSystem;
        crossSystem.system = buildSystem;
      })
      .pkgsStatic
      .busybox;

    recurseForDerivations = true;
  })
