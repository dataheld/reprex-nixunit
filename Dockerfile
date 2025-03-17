FROM nixpkgs/nix-flakes:nixos-24.11-aarch64-linux
WORKDIR /src
COPY . .

RUN nix run 'https://flakehub.com/f/DeterminateSystems/flake-iter/*' -- --verbose build
