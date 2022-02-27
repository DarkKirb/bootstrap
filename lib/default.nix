system: { nixpkgs, ... } @ args: rec {
  pkgs = import nixpkgs { inherit system; };
  inherit (builtins) toFile;

  runCommandBasic = script: builtins.derivation {
    inherit system;
    name = "runCommandBasic";
    builder = "${pkgs.busybox}/bin/sh";
    args = [ (toFile "builder.sh" script) ];
  };

  writeTextFile =
    { name
    , text
    , executable ? false
    , destination ? ""
    , checkPhase ? ""
    }: runCommandBasic ''
      target=$out${destination}
      mkdir -p "$(dirname "$target")"

      if [ -e "$textPath" ]; then
        mv "$textPath" "$target"
      else
        echo -n "$text" > "$target"
      fi

      eval "$checkPhase"
      (test -n "$executable" && chmod +x "$target") || true
    '';
  writeText = name: text: writeTextFile { inherit name text; };
  writeTextDir = path: text: writeTextFile {
    inherit text;
    name = builtins.baseNameOf path;
    destination = "/${path}";
  };
  writeScript = name: text: writeTextFile { inherit name text; executable = true; };
  writeScriptBin = name: text: writeTextFile { inherit name text; executable = true; destination = "/bin/${name}"; };

  baseDerivation = { script, ... } @args: builtins.derivation (args // {
    inherit system;
    builder = "${pkgs.busybox}/bin/sh";
    args = [ (writeScript "${args.name}-builder.sh" script) ];
  });
}
