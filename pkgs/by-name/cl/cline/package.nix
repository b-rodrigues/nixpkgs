{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  coreutils,
  procps,
  ripgrep,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  sources ? lib.importJSON ./sources.json,
}:

let
  inherit (sources) version;
  source =
    sources.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "cline";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@cline/cli-${source.platform}/-/cli-${source.platform}-${version}.tgz";
    inherit (source) hash;
  };

  # Prevent bun runtime stripping
  dontStrip = true;

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/cline $out/bin
    cp -r * $out/lib/cline/

    makeWrapper $out/lib/cline/bin/cline $out/bin/cline \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          procps
          ripgrep
        ]
      }

    runHook postInstall
  '';

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru = {
    inherit sources;
    updateScript = ./update.sh;
  };

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
}
