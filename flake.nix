{
  description = "Bootstrap Flake";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils } @ args: with nixpkgs.lib; with flake-utils.lib; eachSystem [
    "armv7l-linux"
    "aarch64-linux"
    "powerpc-linux"
    "powerpc64-linux"
    "powerpc64le-linux"
    "riscv32-linux"
    "riscv64-linux"
    "x86_64-linux"
    "i686-linux"
  ]
    (system: rec {
      packages = lists.foldl (a: b: a // b) { }
        (builtins.map (f: import f system args) [
          ./bin0
        ]);
      lib = import ./lib system args;
      hydraJobs = packages;
    });
}
