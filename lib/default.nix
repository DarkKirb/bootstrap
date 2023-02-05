system: {nixpkgs, ...} @ args: rec {
  inherit (builtins) toFile;

  allPrebuilds = builtins.path {
    path = ../prebuilt;
    sha256 = "sha256-TEPsjuw7VzZSmBJNR0XxNnD3jVBh6aXll+3N3ZQpO3g=";
  };

  prebuilts = "${allPrebuilds}/${system}";

  baseDerivation = {script, ...} @ args:
    builtins.derivation (args
      // {
        inherit system;
        builder = "${prebuilts}/busybox";
        PATH = "${prebuilts}";
        args = [
          "sh"
          (toFile "${args.name}-builder.sh" ''
            set -ex
            eval "$script"
          '')
        ];
      });
}
