{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  installShellFiles,
  nix-update-script,
  stdenv,
  testers,
  roborev,
}:

buildGoModule (finalAttrs: {
  pname = "roborev";
  version = "0.56.0";

  src = fetchFromGitHub {
    owner = "kenn-io";
    repo = "roborev";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VSIY9v23XqX4BRhUJr/Aw8QGg1+RVDsZvK0LxTAPC4U=";
  };

  vendorHash = "sha256-b6B4hR84k3rluvfIP8gRdJpfepiH7xKCRKblbKTHHWc=";

  subPackages = [ "cmd/roborev" ];

  ldflags = [
    "-s"
    "-w"
    "-X go.kenn.io/roborev/internal/version.Version=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ git ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd roborev \
      --bash <($out/bin/roborev completion bash) \
      --fish <($out/bin/roborev completion fish) \
      --zsh <($out/bin/roborev completion zsh)
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = roborev;
      command = "roborev version";
      version = "v${finalAttrs.version}";
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Continuous background code review database for AI agents";
    homepage = "https://github.com/kenn-io/roborev";
    license = lib.licenses.mit;
    mainProgram = "roborev";
    maintainers = with lib.maintainers; [ b-rodrigues ];
  };
})
