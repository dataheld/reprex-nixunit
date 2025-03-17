{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    flake-iter.url = "https://flakehub.com/f/DeterminateSystems/flake-iter/0.1.*";
    nix-unit = {
      url = "github:nix-community/nix-unit/?tag=v2.24.1";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-unit.modules.flake.default
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { 
          pkgs,
          inputs',
          self',
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs'.flake-iter.packages.default
            ];
          };
          nix-unit = {
            inputs = {
              # NOTE: a `nixpkgs-lib` follows rule is currently required
              inherit (inputs) nixpkgs flake-parts nix-unit;
            };
            tests = {
              "test example" = {
                expr = "123";
                expected = "123";
              };
            };
          };
        };
    };
}
