{pkgs, crane, fenix, system}:
  let
    craneLib = crane.mkLib pkgs;
    capnpFilter = path: _type: builtins.match ".*capnp$" path != null;
    capnpOrCargo = path: type: (capnpFilter path type) || (craneLib.filterCargoSources path type);
    unfilteredRoot = ./.;
    src = lib.cleanSourceWith {
      src = unfilteredRoot;
      filter = capnpOrCargo;
      name = "source";
    };

    inherit (pkgs) lib;

    commonArgs = {
      inherit src;
      strictDeps = true;
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

      nativeBuildInputs = [pkgs.capnproto];
    };
    fileSetForCrate = crate: lib.fileset.toSource {
      root = unfilteredRoot;
      fileset = lib.fileset.unions [
        ./Cargo.toml
        ./Cargo.lock
        (craneLib.fileset.commonCargoSources ./protocols_rs)
        (lib.fileset.fileFilter (file: file.hasExt "capnp") unfilteredRoot)
        ./protocols_rs/protocols
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
