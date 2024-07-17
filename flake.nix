{
  description = "Bootstrap";

  outputs = {
    self,
    nixpkgs,
  }: {
    legacyPackages = {
      x86_64-linux = import ./. {
        inherit nixpkgs;
        buildSystem = "x86_64-linux";
      };
      aarch64-linux = import ./. {
        inherit nixpkgs;
        buildSystem = "aarch64-linux";
      };
      riscv64-linux = import ./. {
        inherit nixpkgs;
        buildSystem = "riscv64-linux";
      };
    };
    hydraJobs = import ./hydra.nix {inherit nixpkgs;};
  };
}
