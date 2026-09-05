{
  lib,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv,
  bash,
  coreutils,
  curl,
  findutils,
  gawk,
  git,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  jq,
  procps,
  ripgrep,
  which,
  extraPackages ? [ ],
  sources ? lib.importJSON ./sources.json,
}:

let
  inherit (sources) version;
  source =
    sources.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  cline-unwrapped = stdenvNoCC.mkDerivation {
    pname = "cline-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@cline/cli-${source.platform}/-/cli-${source.platform}-${version}.tgz";
      inherit (source) hash;
    };

    # Prevent bun runtime stripping
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/cline
      cp -r * $out/lib/cline/

      runHook postInstall
    '';

    passthru.exePath = "/lib/cline/bin/cline";

    meta = {
      description = "Autonomous coding agent CLI - capable of creating/editing files, running commands, and more";
      homepage = "https://cline.bot";
      changelog = "https://github.com/cline/cline/releases";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ b-rodrigues ];
      platforms = lib.attrNames sources.sources;
      mainProgram = "cline";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };
in
buildFHSEnv {
  pname = "cline";
  inherit version;

  # Tools that must be available to the agent inside the FHS sandbox: the
  # wrapped binary invokes ripgrep/procps itself, and shell commands it
  # generates expect a standard Unix userland. Project-specific toolchains
  # (nodejs, python, compilers, ...) can be added via `extraPackages`.
  targetPkgs =
    pkgs: with pkgs; [
      bash
      coreutils
      curl
      findutils
      gawk
      git
      gnugrep
      gnused
      gnutar
      gzip
      jq
      procps
      ripgrep
      which
    ]
    ++ extraPackages;

  runScript = "${cline-unwrapped}${cline-unwrapped.exePath}";

  passthru = {
    inherit sources cline-unwrapped;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Autonomous coding agent CLI - capable of creating/editing files, running commands, and more";
    homepage = "https://cline.bot";
    changelog = "https://github.com/cline/cline/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
    platforms = lib.platforms.linux;
    mainProgram = "cline";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
