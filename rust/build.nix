{pkgs, crane, fenix, system}:
  let
    craneLib = crane.mkLib pkgs;
    src = craneLib.cleanCargoSource ./.;

    inherit (pkgs) lib;

    commonArgs = {
      inherit src;
      strictDeps = true;

      buildInputs = [pkgs.capnproto];
    };
    craneLibLLvmTools = craneLib.overrideToolchain (fenix.packages.${system}.complete.withComponents [
"cargo"
"llvm-tools"
"rustc"
    ]);

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    individualCrateArgs = commonArgs // {
      inherit cargoArtifacts;
      inherit (craneLib.crateNameFromCargoToml { inherit src;}) version;
      doCheck = false;
    };

    fileSetForCrate = crate: lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Cargo.toml
        ./Cargo.lock
        (craneLib.fileset.commonCargoSources ./protocols_rs)
        (craneLib.fileset.commonCargoSources crate)
      ];
    };
    pinger = craneLib.buildPackage (individualCrateArgs // {
      pname = "pinger";
      cargoExtraArgs = "-p pinger";
      src = fileSetForCrate ./pinger;
    });
    in with pkgs; {
        inherit pinger;
      devPkgs = [cowsay];
    }
