{
  stdenv,
  yarn,
  nodejs,
#  jq,
  git,
#  gcc,
  pkg-config,
  libX11,
  libxkbfile,
  libsecret,
  libkrb5,
  #cmake,
  lib,
  fetchgit,
  fetchYarnDeps,
  fixup-yarn-lock,
  python3,
  quarto
}:

let
  pname = "positron";
  version = "2024.08.0-48";
  POSITRON_VERSION_MAJOR = lib.versions.major version;
  POSITRON_VERSION_MINOR = lib.versions.minor version;
  POSITRON_VERSION_PATCH = lib.versions.patch version;
  POSITRON_VERSION_SUFFIX = "-" + toString (lib.tail (lib.splitString "-" version));

  src = fetchgit {
    url = "https://github.com/posit-dev/positron";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-nDbS14F1x/f+jxkQ+bKB2qQi/JXks6gK9zj7Coxchq0=";
  };

  OfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-++m6+BhWb3HW0Jkcx9wh9uilPM4flLO/KD+9wRzwvqE=";
  };

  buildOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/build/yarn.lock";
    hash = "sha256-sZ052z+z0g3lXPmij2iBPKVAS7rl4RrUVXOy9nqcM2Q=";
  };

  remoteOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/remote/yarn.lock";
    hash = "sha256-kNTdE88ten3zXM64MAh0CJGVXqOh//Z9JUoBSrp6fqY=";
  };
  extensionsOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/extensions/yarn.lock";
    hash = "sha256-3x7qVxtW3flSUKns04ux/zAWE0q/c2sF+YeCNxogkn0=";
  };
in
stdenv.mkDerivation {

    inherit pname version src POSITRON_VERSION_MAJOR POSITRON_VERSION_MINOR POSITRON_VERSION_PATCH POSITRON_VERSION_SUFFIX;


    nativeBuildInputs = [
      yarn
      fixup-yarn-lock
      nodejs
      #jq
      git
      #gcc
      #cmake
      pkg-config
      libX11
      libxkbfile
      libsecret
      libkrb5
      python3
    ];

  buildInputs = [
   quarto
  ];

  configurePhase = ''
    runHook preConfigure

    export HOME=$PWD/home

    configureDependencies () {
      yarn config --offline set yarn-offline-mirror $1
      fixup-yarn-lock "$2/yarn.lock"
      yarn install --offline --cwd "$2" --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive

      patchShebangs "$2/node_modules/"
    }

    configureDependencies ${OfflineCache} "."
    configureDependencies ${buildOfflineCache} "./build"
    configureDependencies ${remoteOfflineCache} "./remote"
    configureDependencies ${extensionsOfflineCache} "./extensions"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline compile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv build $out

    runHook postInstall
  '';

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
