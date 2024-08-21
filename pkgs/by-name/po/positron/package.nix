{
  stdenv,
  yarn,
  nodejs,
  jq,
  git,
  gcc,
  pkg-config,
  libX11,
  libxkbfile,
  libsecret,
  libkrb5,
  cmake,
  lib,
  fetchFromGitHub,
  quarto
}:

let
  pname = "positron";
  version = "2024.08.0-48";
  POSITRON_VERSION_MAJOR = lib.versions.major version;
  POSITRON_VERSION_MINOR = lib.versions.minor version;
  POSITRON_VERSION_PATCH = lib.versions.patch version;
  POSITRON_VERSION_SUFFIX = "-" + toString (lib.tail (lib.splitString "-" version));

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "positron";
    rev = version;
    hash = "sha256-nDbS14F1x/f+jxkQ+bKB2qQi/JXks6gK9zj7Coxchq0=";
  };
in
stdenv.mkDerivation {

    inherit pname version src POSITRON_VERSION_MAJOR POSITRON_VERSION_MINOR POSITRON_VERSION_PATCH POSITRON_VERSION_SUFFIX;

    nativeBuildInputs = [
      yarn
      nodejs
      jq
      git
      gcc
      cmake
      pkg-config
      libX11
      libxkbfile
      libsecret
      libkrb5
    ];

  buildInputs = [
   quarto
  ];

  meta = {
    description = "Positron, a next-generation data science IDE";
    longDescription = ''
      Positron is an extensible, polyglot IDE built by Posit PBC.
    '';
    homepage = "https://github.com/posit-dev/positron";
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
