{
  description = "moxon antenna frame generator";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;
      forAllSystems = with nixpkgs.lib;
        fn:
        genAttrs systems (system:
          fn {
            pkgs = import nixpkgs { inherit system; };
            inherit system;
          });
    in {
      devShells = forAllSystems ({ pkgs, ... }: {
        default = pkgs.mkShell { buildInputs = [ pkgs.openscad-unstable ]; };
      });
    };
}
