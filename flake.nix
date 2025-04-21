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
      in with pkgs;
            {
              devShells.default = mkShell {
                buildInputs = [ capnproto ];
              };
            });
}
