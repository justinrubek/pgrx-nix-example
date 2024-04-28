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
    process-compose.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:justinrubek/services-flake";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        inputs.process-compose.flakeModule
        ./flake-parts/services.nix
        ./flake-parts/postgres.nix
      ];
      perSystem = {
        pkgs,
        system,
        inputs',
        self',
        ...
      }: {
        devShells.default = pkgs.mkShell {
          packages = [self'.packages.postgresql];
        };
        packages = {
          pgrx-arrays = inputs.pgrx.lib.buildPgrxExtension {
            inherit system;
            postgresql = self'.packages.postgresql-target;
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
