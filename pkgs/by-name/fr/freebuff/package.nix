{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  autoPatchelfHook,
  testers,
  git,
  ripgrep,
  cacert,
  curl,
  bubblewrap,
  freebuff,
}:

let
  version = "0.2.33";

  sources = {
    x86_64-linux = {
      asset = "freebuff-linux-x64.tar.gz";
      hash = "sha256-oB6Ozse/5MiVz4KRMefYU6WjsJLe1a1tO71+0ltLy64=";
    };
    aarch64-linux = {
      asset = "freebuff-linux-arm64.tar.gz";
      hash = "sha256-/vauvw6z07ZvG68ITE2M7RkPmQRyuZLtaOURO0DUgdk=";
    };
    x86_64-darwin = {
      asset = "freebuff-darwin-x64.tar.gz";
      hash = "sha256-EVBVxj4VlSMGDg61HslA88eW9rjHIlqfJqXw+uBK0p8=";
    };
    aarch64-darwin = {
      asset = "freebuff-darwin-arm64.tar.gz";
      hash = "sha256-gKwMI4SVQ/EcudrdyyVpC18SgE9kgRJxIlIjlytWDeM=";
    };
  };

  srcInfo =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = {
    description = "Free AI coding assistant";
    homepage = "https://freebuff.com";
    downloadPage = "https://github.com/CodebuffAI/codebuff-community/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
    mainProgram = "freebuff";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "freebuff-unwrapped";
    inherit version meta;

    src = fetchurl {
      url = "https://github.com/CodebuffAI/codebuff-community/releases/download/freebuff-v${finalAttrs.version}/${srcInfo.asset}";
      inherit (srcInfo) hash;
    };

    sourceRoot = ".";

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 freebuff -t $out/bin/
      install -Dm644 tree-sitter.wasm -t $out/bin/

      runHook postInstall
    '';
  });

  fhs = buildFHSEnv {
    pname = "freebuff";
    inherit version meta;

    targetPkgs =
      pkgs: with pkgs; [
        unwrapped
        git
        ripgrep
        cacert
        curl
        bubblewrap
      ];

    runScript = "freebuff";

    extraInstallCommands = ''
      mkdir -p $out/share
    '';

    passthru = {
      inherit unwrapped;
      updateScript = ./update.sh;
      tests.version = testers.testVersion {
        # The FHS wrapper needs user namespaces (bubblewrap), which aren't
        # available in the Nix build sandbox, so exercise the unwrapped binary
        # the wrapper ultimately execs.
        package = unwrapped;
        command = "HOME=$(mktemp -d) freebuff --version";
        inherit version;
      };
    };
  };
in
if stdenv.hostPlatform.isLinux then
  fhs
else
  unwrapped.overrideAttrs (old: {
    pname = "freebuff";
    passthru = (old.passthru or { }) // {
      inherit unwrapped;
      updateScript = ./update.sh;
      tests.version = testers.testVersion {
        package = freebuff;
        command = "HOME=$(mktemp -d) freebuff --version";
        inherit version;
      };
    };
  })
