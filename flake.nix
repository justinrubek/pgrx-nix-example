{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-filter.url = "github:numtide/nix-filter";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pgrx = {
      url = "github:justinrubek/pgrx/reintroduce-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        pkgs,
        system,
        inputs',
        ...
      }: {
        packages = {
          pgrx-arrays = inputs.pgrx.lib.buildPgrxExtension {
            inherit system;
            postgresql = pkgs.postgresql_15;
            rustToolchain = inputs'.fenix.packages.stable.toolchain;
            src = inputs.nix-filter.lib {
              root = ./.;
              include = [
                "src"
                "Cargo.toml"
                "Cargo.lock"
                "arrays.control"
              ];
            };
          };
        };
      };
    };
}
