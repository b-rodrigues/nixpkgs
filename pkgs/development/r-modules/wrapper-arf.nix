{
  lib,
  runCommand,
  R,
  arf,
  makeBinaryWrapper,
  recommendedPackages,
  packages,
}:

runCommand (arf.name + "-wrapper")
  {
    preferLocalBuild = true;
    allowSubstitutes = false;

    buildInputs = [
      R
      arf
    ]
    ++ recommendedPackages
    ++ packages;

    nativeBuildInputs = [ makeBinaryWrapper ];

    passthru = { inherit recommendedPackages; };

    meta = arf.meta // {
      # To prevent builds on hydra
      hydraPlatforms = [ ];
      # prefer wrapper over the package
      priority = (arf.meta.priority or lib.meta.defaultPriority) - 1;
    };
  }
  ''
    makeWrapper "${arf}/bin/arf" "$out/bin/arf" \
      --prefix "R_LIBS_SITE" ":" "$R_LIBS_SITE"
  ''
