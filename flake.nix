{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, nixpkgs }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay.${system} ];
        };
      in {
        overlay = self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages.overrideScope'
            (self: super: {
              genhash = super.buildDunePackage {
                pname = "genhash";
                version = "0.1";
                duneVersion = "3";
                minimalOCamlVersion = "4.08";
                src = ./.;
                propagatedBuildInputs = [ self.integers self.core ];
              };
            });
        };
        defaultPackage = pkgs.ocamlPackages.genhash;
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.ocamlformat pkgs.ocamlPackages.ocaml-lsp ];
          inputsFrom = [ pkgs.ocamlPackages.genhash ];
        };
      });
}
