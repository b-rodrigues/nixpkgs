{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  R,
  glibcLocales ? null,
  air-formatter,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arf";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "eitsupi";
    repo = "arf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b2O87n90JqMzOQMxsaf78GIKteG7IXynJSTpn32V/cM=";
  };

  cargoHash = "sha256-v71Zy+1uI3jVQ3nek5+f5TKoN+wXK89VpFx0vcbZjIE=";

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [
    R
    air-formatter
  ]
  ++ lib.optionals (glibcLocales != null) [ glibcLocales ];

  preCheck = ''
    export HOME=$TMPDIR
    export TERM=xterm-256color
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
  ''
  + lib.optionalString (glibcLocales != null) ''
    export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
  '';

  postInstall = ''
    wrapProgram $out/bin/arf \
      --prefix PATH : ${lib.makeBinPath [ R ]} \
      --set R_HOME ${R}/lib/R
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Alternative R Frontend — a modern R console written in Rust";
    homepage = "https://github.com/eitsupi/arf";
    changelog = "https://github.com/eitsupi/arf/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "arf";
    maintainers = [ lib.maintainers.brancengregory ];
  };
})
