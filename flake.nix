{
  description = "HomeOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    opam-nix.url = "github:tweag/opam-nix";
};

  outputs = {self, nixpkgs, flake-utils, opam-nix}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
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
        ocamlDevPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
        ocamlPackages = pkgs.lib.getAttrs (builtins.attrNames localPackagesQuery) scope;
      in with pkgs;
            rec {
              legacyPackages = scope;
              packages = ocamlPackages;
              devShells.default = mkShell {
                inputsFrom = builtins.attrValues ocamlPackages;
                buildInputs = [ capnproto ] ++ ocamlDevPackages;
              };
            });
}
