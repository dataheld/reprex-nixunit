{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0.1.*";
    flake-checker.url = "https://flakehub.com/f/DeterminateSystems/flake-checker/0.2.*";
    flake-iter.url = "https://flakehub.com/f/DeterminateSystems/flake-iter/0.1.*";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "https://flakehub.com/f/hercules-ci/flake-parts/0.1.*";
    };
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/0.1.*";
    nix-unit = {
      url = "github:nix-community/nix-unit/?tag=v2.24.1";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix/3d0579f5cc93436052d94b73925b48973a104204";
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
          inputs',
          pkgs,
          self',
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs'.fh.packages.default
              inputs'.flake-checker.packages.default
              inputs'.flake-iter.packages.default
              pkgs.git
              pkgs.gnumake
              pkgs.nixd
              self'.formatter
            ];
          };
          nix-unit.inputs = {
            # NOTE: a `nixpkgs-lib` follows rule is currently required
            inherit (inputs) nixpkgs flake-parts nix-unit;
          };
          # Tests specified here may refer to system-specific attributes that are
          # available in the `perSystem` context
          nix-unit.tests = {
            "test integer equality is reflexive" = {
              expr = "123";
              expected = "123";
            };
            "frobnicator" = {
              "testFoo" = {
                expr = "foo";
                expected = "foo";
              };
            };
          };
        };
      flake = {
        schemas = inputs.flake-schemas.schemas;
        # System-agnostic tests can be defined here, and will be picked up by
        # `nix flake check`
        tests.testBar = {
          expr = "bar";
          expected = "bar";
        };
      };
    };
}
