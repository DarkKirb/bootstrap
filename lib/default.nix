system: { nixpkgs, ... } @ args: rec {
  inherit (builtins) toFile;

  baseDerivation = { script, ... } @args: builtins.derivation (args // {
    inherit system;
    builder = ./. + "/../prebuilt/${system}/busybox";
    args = [
      "sh"
      (toFile "${args.name}-builder.sh" (
        ''
          set -ex
          export PATH=${./. + "/../prebuilt/${system}"}
          eval "$script"
        ''
      ))
    ];
  });
}
