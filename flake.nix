{
  description = "A tool to manage Nix GC root symlinks";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: {
    overlays = {
      poetry2nix = inputs.poetry2nix.overlays.default;
      default = final: prev: {
        nixgcmgr = final.callPackage ./default.nix {
          python3Packages = final.python311Packages;
        };
      };
    };
  } // (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system; overlays = nixpkgs.lib.attrValues self.overlays;
    };
  in {
    packages = {
      nixgcmgr = pkgs.nixgcmgr;
      default = self.packages.${system}.nixgcmgr;
    };

    devShells.default = pkgs.mkShell {
      inputsFrom = [ self.packages.${system}.default ];
      nativeBuildInputs = with pkgs; [ mypy ];
      PIP_DISABLE_PIP_VERSION_CHECK = "true";
    };
  }));
}
