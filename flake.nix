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
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";
    nix-unit.inputs.flake-parts.follows = "flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-unit.modules.flake.default
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
        # System-agnostic tests can be defined here, and will be picked up by
        # `nix flake check`
        tests.testBar = {
          expr = "bar";
          expected = "bar";
        };
      };
    };
}
