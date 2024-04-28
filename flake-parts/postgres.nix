{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages = rec {
      postgresql-target = pkgs.postgresql_15;
      postgresql = self'.packages.postgresql-target.withPackages (ps: [self'.packages.pgrx-arrays]);
    };
  };
}
