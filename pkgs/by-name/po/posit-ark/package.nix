{ lib
, cargo
, rustc
, rustPlatform
, fetchgit
, pkg-config
, stdenv
}:

let
  pname = "posit-ark";
  version = "0.1.129";
  src = fetchgit {
    url = "https://github.com/posit-dev/ark";
    rev = version;
    hash = "sha256-yXjwG+uDrNtx9/FffGwG9ccGVgBkJe068BYhtp/01pU=";
  };
in
rustPlatform.buildRustPackage {

  inherit pname version src;

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
    outputHashes = {
      "dap-0.4.1-alpha1" = "sha256-nUsTazH1riI0nglWroDKDWoHEEtNEtpwn6jCH2N7Ass=";
      "tree-sitter-r-0.20.1" = "sha256-IMIouN0wi1xd9SAzORYVkLzj78HUu3u4r4OyMUj+6SE=";
    };
  };

  doCheck = false;

  nativeBuildInputs = [
    cargo
    rustc
    #pkg-config
    #rustPlatform.bindgenHook
  ];

  meta = with lib; {
    description = "Ark, an R Kernel for Jupyter applications";
    homepage = "https://github.com/posit-dev/ark";
    changelog = "https://github.com/posit-dev/ark/releases/tag/${src.rev}";
    license = licenses.mit;
    maintainers = with maintainers; [ b-rodrigues ];
  };
}
