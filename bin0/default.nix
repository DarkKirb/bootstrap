system: { self, nixpkgs, ... } @ args: with self.lib.${system}; with nixpkgs.lib; if lists.any (s: system == s) [
  "armv7l-linux"
  "aarch64-linux"
  "powerpc-linux"
] then
  rec {
    bin0-bin = baseDerivation {
      name = "bin0-bin";
      script = ''
        set -ex
        cp ${./. + "/${system}/bin0"} $out
      '';
    };
    bin0 = baseDerivation {
      name = "bin0";
      script = ''
        set -ex
        ${bin0-bin} ${./. + "/${system}/bin0.bin0"} $out
      '';
    };
  } else { }
