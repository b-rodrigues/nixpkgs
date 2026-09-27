{
  lib,
  stdenvNoCC,
  bun,
  darwin,
  fetchFromGitHub,
  makeBinaryWrapper,
  models-dev,
  nodejs,
  nix-update-script,
  ripgrep,
  sysctl,
  wayland,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  node_modules =
    finalAttrs:
    let
      platform = stdenvNoCC.hostPlatform;
      bunCpu = if platform.isAarch64 then "arm64" else "x64";
      bunOs = if platform.isLinux then "linux" else "darwin";
    in
    stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-node_modules";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="${bunCpu}" \
          --os="${bunOs}" \
          --filter '!./' \
          --filter './packages/cli' \
          --filter './packages/desktop' \
          --filter './packages/app' \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress

        bun --bun ./nix/scripts/canonicalize-node-modules.ts
        bun --bun ./nix/scripts/normalize-bun-binaries.ts

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;

        runHook postInstall
      '';

      dontFixup = true;

      outputHash = (lib.importJSON ./hashes.json).${stdenvNoCC.hostPlatform.system};
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode2";
  version = "2.0.18";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QyzzA9SUnnCunYucJPjZAw/EkUN1EKoDcrFalIOYVps=";
  };

  postPatch = ''
    # Relax Bun version check to be a warning instead of an error
    substituteInPlace packages/script/src/index.ts \
      --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
                     'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
  '';

  nativeBuildInputs = [
    bun
    nodejs
    makeBinaryWrapper
    models-dev
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.passthru.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  env.MODELS_DEV_API_JSON = "${models-dev}/dist/_api.json";
  env.OPENCODE_DISABLE_MODELS_FETCH = true;
  env.OPENCODE_VERSION = finalAttrs.version;
  env.OPENCODE_CHANNEL = "prod";
  env.NODE_OPTIONS = "--max-old-space-size=4096";

  buildPhase = ''
    runHook preBuild

    cd ./packages/cli
    bun --bun ./script/build.ts --single --skip-install

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 dist/cli-*/bin/opencode $out/bin/opencode2

    wrapProgram $out/bin/opencode2 \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            ripgrep
          ]
          ++ lib.optional stdenvNoCC.hostPlatform.isDarwin sysctl
        )
      } ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland ]} \
      ''}--set OPENCODE_DISABLE_AUTOUPDATE true \
      --set OPENCODE_DB opencode2.db

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    codesign --force --sign - $out/bin/.opencode2-wrapped
  '';

  dontStrip = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  doInstallCheck = true;
  versionCheckKeepEnvironment = [
    "HOME"
    "OPENCODE_DISABLE_MODELS_FETCH"
  ];
  versionCheckProgramArg = "--version";

  passthru = {
    node_modules = node_modules finalAttrs;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v(2\\..*)$"
      ];
    };
  };

  meta = {
    description = "AI coding agent built for the terminal (v2)";
    homepage = "https://github.com/anomalyco/opencode";
    changelog = "https://github.com/anomalyco/opencode/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      delafthi
      DuskyElf
      graham33
    ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    mainProgram = "opencode2";
  };
})
