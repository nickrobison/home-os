{
  description = "HomeOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    crane.url = "github:ipetkov/crane";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opam-nix,
      crane,
      fenix,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        on = opam-nix.lib.${system};
        localPackagesQuery = builtins.mapAttrs (_: pkgs.lib.last) (on.listRepo (on.makeOpamRepo ./ocaml));
        devPackagesQuery = {
          ocaml-lsp-server = "*";
          merlin = "*";
          ocamlformat = "0.27.0";
        };
        query = devPackagesQuery // {
          ocaml-base-compiler = "*";
        };
        scope = on.buildOpamProject' { } ./ocaml query;
        ocamlDevPackages = builtins.attrValues (
          pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope
        );
        ocamlPackages = pkgs.lib.getAttrs (builtins.attrNames localPackagesQuery) scope;
        rustPackages = (
          pkgs.callPackage ./rust/build.nix {
            inherit fenix;
            inherit crane;
          }
        );
      in
      with pkgs;
      rec {
        formatter = treefmtEval.config.build.wrapper;
        checks = {
          formatting = treefmtEval.config.build.check self;
        };
        legacyPackages = scope;
        packages = {
          inherit ocamlPackages;
          pinger = rustPackages.pinger;
        };
        devShells.default = mkShell {
          inputsFrom = builtins.attrValues ocamlPackages ++ [ rustPackages.pinger ];
          buildInputs = [ capnproto ] ++ ocamlDevPackages ++ rustPackages.devPkgs;
        };
      }
    );
}
