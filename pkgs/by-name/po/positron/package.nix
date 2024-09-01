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
  posit-ark,
  fetchgit,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  prefetch-yarn-deps,
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

  buildGypOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/build/npm/gyp/yarn.lock";
    hash = "sha256-WrjKSQDDBPwW2f2KqcIHfdN1A3nCMeKZog5U6ChgGIA=";
  };

  remoteOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/remote/yarn.lock";
    hash = "sha256-kNTdE88ten3zXM64MAh0CJGVXqOh//Z9JUoBSrp6fqY=";
  };

  remoteReh-WebOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/remote/reh-web/yarn.lock";
    hash = "sha256-2VH4gaod2Uh7ly0BwfuZFBSVSZSMlcb5OsP4GsoaJtg=";
  };

  remoteWebOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/remote/web/yarn.lock";
    hash = "sha256-2VH4gaod2Uh7ly0BwfuZFBSVSZSMlcb5OsP4GsoaJtg=";
  };

  extensionsOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/extensions/yarn.lock";
    hash = "sha256-3x7qVxtW3flSUKns04ux/zAWE0q/c2sF+YeCNxogkn0=";
  };

  extensionsConfiguration-EditingOfflineCache = fetchYarnDeps {
    name = "configuration-editing";
    yarnLock = "${src}/extensions/configuration-editing/yarn.lock";
    hash = "sha256-7Sp+ZwrL5arv9lqU+iJcm8cjudGVDmPG0TLXp4l+xKE=";
  };

  extensionsCSS-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "css-language-features";
    yarnLock = "${src}/extensions/css-language-features/yarn.lock";
    hash = "sha256-BAui4m5aj4XcDq42R6TNPEcPppSOg//NwOnpuiEBp/M=";
  };

  extensionsDebug-Auto-LaunchOfflineCache = fetchYarnDeps {
    name = "debug-auto-launch";
    yarnLock = "${src}/extensions/debug-auto-launch/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsDebug-Server-ReadyOfflineCache = fetchYarnDeps {
    name = "debug-server-ready";
    yarnLock = "${src}/extensions/debug-server-ready/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsEmmetOfflineCache = fetchYarnDeps {
    name = "emmet";
    yarnLock = "${src}/extensions/emmet/yarn.lock";
    hash = "sha256-Xfm0K75LC3Xu1HKWF8mFVbkl9lDsNN3c07pC7+vgSPs=";
  };

  extensionsExtension-EditingOfflineCache = fetchYarnDeps {
    name = "extension-editing";
    yarnLock = "${src}/extensions/extension-editing/yarn.lock";
    hash = "sha256-ZK2fe2Ap5RryFd8v+BxPHTjV6ox9I0LXL9g5L9OCTBA=";
  };

  extensionsGit-BaseOfflineCache = fetchYarnDeps {
    name = "git-base";
    yarnLock = "${src}/extensions/git-base/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsGitOfflineCache = fetchYarnDeps {
    name = "git";
    yarnLock = "${src}/extensions/git/yarn.lock";
    hash = "sha256-EQ7DNfCOO+pEavfRMsrwO/UNHRUe6PWBV8qXrRhteLY=";
  };

  extensionsGithub-AuthenticationOfflineCache = fetchYarnDeps {
    name = "github-authentication";
    yarnLock = "${src}/extensions/github-authentication/yarn.lock";
    hash = "sha256-PSG2gWPavZNzcGH1lwn1NLRRMqdjYi+c9NJYRfpmED8=";
  };

  extensionsGithubOfflineCache = fetchYarnDeps {
    name = "github";
    yarnLock = "${src}/extensions/github/yarn.lock";
    hash = "sha256-cr6gx50Jo1khqamOooJ1ebjbYmMwtiiGFAwZQslKEUo=";
  };

  extensionsGruntOfflineCache = fetchYarnDeps {
    name = "grunt";
    yarnLock = "${src}/extensions/grunt/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsGulpOfflineCache = fetchYarnDeps {
    name = "gulp";
    yarnLock = "${src}/extensions/gulp/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsHtml-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "html-language-features";
    yarnLock = "${src}/extensions/html-language-features/yarn.lock";
    hash = "sha256-gpxj3TRTA+WY4f3KZI3bTTiaNVPDZmVWyUurCfcykJU=";
  };

  extensionsIpynbOfflineCache = fetchYarnDeps {
    name = "ipynb";
    yarnLock = "${src}/extensions/ipynb/yarn.lock";
    hash = "sha256-YadaeZgH4Q2fivoXQip+W/suI8ub7xJ+U2+0CIv5vBc=";
  };

  extensionsJakeOfflineCache = fetchYarnDeps {
    name = "jake";
    yarnLock = "${src}/extensions/jake/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsJson-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "json-language-features";
    yarnLock = "${src}/extensions/json-language-features/yarn.lock";
    hash = "sha256-qFG0oDJ2yVLFKhoTj32ShZTOe4Vy2eVzMALPUqtzCoI=";
  };

  extensionsJupyter-AdapterOfflineCache = fetchYarnDeps {
    name = "jupyter-adapter";
    yarnLock = "${src}/extensions/jupyter-adapter/yarn.lock";
    hash = "sha256-GxAwLHvCgygRLd/imc/1RXmUhenU+dKacDx7i+nzGE4=";
  };

  extensionsMarkdown-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "markdown-language-features";
    yarnLock = "${src}/extensions/markdown-language-features/yarn.lock";
    hash = "sha256-+T/5ZHvAj5El79yYB6ZV5FgU4pt+pdhBojBMuC3dAAM=";
  };

  extensionsMarkdown-MathOfflineCache = fetchYarnDeps {
    name = "markdown-math";
    yarnLock = "${src}/extensions/markdown-math/yarn.lock";
    hash = "sha256-pwAA9jNvcPve7RbqVsJHlhLLmsb6cfOkNyYijJZkRMA=";
  };

  extensionsMedia-PreviewOfflineCache = fetchYarnDeps {
    name = "media-preview";
    yarnLock = "${src}/extensions/media-preview/yarn.lock";
    hash = "sha256-veltEtQhxmlkSjdAOq3hpDW5fyOX4fr2f6cuhJ57Be8=";
  };

  extensionsMerge-ConflictOfflineCache = fetchYarnDeps {
    name = "merge-conflict";
    yarnLock = "${src}/extensions/merge-conflict/yarn.lock";
    hash = "sha256-trvbycZSceX2Xgk/Job5QRrY3bRf91Ridl/LbTitVfE=";
  };

  extensionsMicrosoft-AuthenticationOfflineCache = fetchYarnDeps {
    name = "microsoft-authentication";
    yarnLock = "${src}/extensions/microsoft-authentication/yarn.lock";
    hash = "sha256-n1hva/HPnP3zRe6nlru8L8QiskzB+TQRfSkD4DQi7Wc=";
  };

  extensionsNotebook-RenderersOfflineCache = fetchYarnDeps {
    name = "notebook-renderers";
    yarnLock = "${src}/extensions/notebook-renderers/yarn.lock";
    hash = "sha256-8v9Y0FKo0CQniL5jfrGf2rCXzH7XiJD+jxsnikODcdY=";
  };

  extensionsNPMOfflineCache = fetchYarnDeps {
    name = "npm";
    yarnLock = "${src}/extensions/npm/yarn.lock";
    hash = "sha256-csnOcZzR1Yoi6H0fo8/imkkgQOF7uEkKW35dM6dIrv4=";
  };

  extensionsOpen-Remote-SSHOfflineCache = fetchYarnDeps {
    name = "open-remote-ssh";
    yarnLock = "${src}/extensions/open-remote-ssh/yarn.lock";
    hash = "sha256-HtwqrPT0I4bdhTZVl9H3XKXEA7Vg42j3XjAnViU9ozI=";
  };

  extensionsPHP-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "php-language-features";
    yarnLock = "${src}/extensions/php-language-features/yarn.lock";
    hash = "sha256-3of1BLvYkJ07wzDyxeLsC2E2I4PjWLjas/fvUQ0Yg+Q=";
  };

  extensionsPositron-Code-CellsOfflineCache = fetchYarnDeps {
    name = "positron-code-cells";
    yarnLock = "${src}/extensions/positron-code-cells/yarn.lock";
    hash = "sha256-rJxShwASsFYO/Frcakm2YW/q6BYlCahPokQGCU2z6sc=";
  };

  extensionsPositron-ConnectionsOfflineCache = fetchYarnDeps {
    name = "positron-connections";
    yarnLock = "${src}/extensions/positron-connections/yarn.lock";
    hash = "sha256-jE7VdlIlaSGr+bCmVRsJBuHPJOP9MwO27vD+8TS0ptI=";
  };

  extensionsPositron-JavascriptOfflineCache = fetchYarnDeps {
    name = "positron-javascript";
    yarnLock = "${src}/extensions/positron-javascript/yarn.lock";
    hash = "sha256-5TCaesVBYfPfFq/FauTlhC+VlHFajV82QA1EgyWFKnQ=";
  };

  extensionsPositron-NotebooksOfflineCache = fetchYarnDeps {
    name = "positron-notebooks";
    yarnLock = "${src}/extensions/positron-notebooks/yarn.lock";
    hash = "sha256-cpmHSJHwt6cD9wtXIm9g/ElgbwRx1Cd9fW1gfsG3FSk=";
  };

  extensionsPositron-ProxyOfflineCache = fetchYarnDeps {
    name = "positron-proxy";
    yarnLock = "${src}/extensions/positron-proxy/yarn.lock";
    hash = "sha256-IB/xJjawCRMv+ORuaR65C3cXvhVRC1mylK4r7iIAgVI=";
  };

  extensionsPositron-PythonOfflineCache = fetchYarnDeps {
    name = "positron-python";
    yarnLock = "${src}/extensions/positron-python/yarn.lock";
    hash = "sha256-pULU/yBQYjg3k8iPi5518yZATHtSkAK0ReRWlwsmDAE=";
  };

  extensionsPositron-ROfflineCache = fetchYarnDeps {
    name = "positron-r";
    yarnLock = "${src}/extensions/positron-r/yarn.lock";
    hash = "sha256-FTfB0WagcI4S9q8imyKxTzgmlMs7mAXTiIdUA0bn3yk=";
  };

  extensionsPositron-ZedOfflineCache = fetchYarnDeps {
    name = "positron-zed";
    yarnLock = "${src}/extensions/positron-zed/yarn.lock";
    hash = "sha256-cpmHSJHwt6cD9wtXIm9g/ElgbwRx1Cd9fW1gfsG3FSk=";
  };

  extensionsReferences-ViewOfflineCache = fetchYarnDeps {
    name = "references-view";
    yarnLock = "${src}/extensions/references-view/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsSimple-BrowserOfflineCache = fetchYarnDeps {
    name = "simple-browser";
    yarnLock = "${src}/extensions/simple-browser/yarn.lock";
    hash = "sha256-zVUsF+nT4Q34fQ7sRRemAkxnTtd0h9nnZOmtDrm5MTY=";
  };

  extensionsTunnel-ForwardingOfflineCache = fetchYarnDeps {
    name = "tunnel-forwarding";
    yarnLock = "${src}/extensions/tunnel-forwarding/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };

  extensionsTypescript-Language-FeaturesOfflineCache = fetchYarnDeps {
    name = "typescript-language-features";
    yarnLock = "${src}/extensions/typescript-language-features/yarn.lock";
    hash = "sha256-tQqgIuksK57T48BBGo0zRZzAFOuUppnXefvV5AAAoPQ=";
  };

  extensionsVscode-Api-TestsOfflineCache = fetchYarnDeps {
    name = "Vscode-Api-Tests";
    yarnLock = "${src}/extensions/vscode-api-tests/yarn.lock";
    hash = "sha256-txQn1EisU2ta3bMVkpbqB5eqW7DYYp9r/FqfLvstVWc=";
  };

  extensionsVscode-Colorize-TestsOfflineCache = fetchYarnDeps {
    name = "Vscode-Colorize-Tests";
    yarnLock = "${src}/extensions/vscode-colorize-tests/yarn.lock";
    hash = "sha256-2a0rQfIV815m6wYTXFBfcQPy3cGBL7MLqhbw3Phr0iw=";
  };

  extensionsVscode-Test-ResolverOfflineCache = fetchYarnDeps {
    name = "Vscode-Test-Resolver";
    yarnLock = "${src}/extensions/vscode-test-resolver/yarn.lock";
    hash = "sha256-be/kKump7AGDesUlY6Sk5XY2eDF2vK1bfe0IpFDzBx8=";
  };
in
stdenv.mkDerivation {

    inherit pname version src POSITRON_VERSION_MAJOR POSITRON_VERSION_MINOR POSITRON_VERSION_PATCH POSITRON_VERSION_SUFFIX;


    nativeBuildInputs = [
      yarn
      yarnConfigHook
      yarnBuildHook
      prefetch-yarn-deps
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

  propagatedNativeBuildInputs = [
   posit-ark
  ];

  configurePhase = ''
    runHook preConfigure

    export HOME=$PWD/home

    configureDependencies () {
      yarn config --offline set yarn-offline-mirror $1
      echo "!!!!!!!!!!!!!!!!!!!!"
      echo "doing $2"
      echo "!!!!!!!!!!!!!!!!!!!!"
      fixup-yarn-lock "$2/yarn.lock"
      yarn install --offline --cwd "$2" --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive

      patchShebangs "$2/node_modules/"
    }

    configureDependencies ${OfflineCache} "."
    configureDependencies ${buildOfflineCache} "./build"
    configureDependencies ${buildGypOfflineCache} "./build/npm/gyp"
    configureDependencies ${remoteOfflineCache} "./remote"
    configureDependencies ${remoteWebOfflineCache} "./remote/web"
    configureDependencies ${extensionsOfflineCache} "./extensions"
    configureDependencies ${extensionsConfiguration-EditingOfflineCache} "./extensions/configuration-editing"
    configureDependencies ${extensionsCSS-Language-FeaturesOfflineCache} "./extensions/css-language-features"
    configureDependencies ${extensionsDebug-Auto-LaunchOfflineCache} "./extensions/debug-auto-launch"
    configureDependencies ${extensionsDebug-Server-ReadyOfflineCache} "./extensions/debug-server-ready"
    configureDependencies ${extensionsEmmetOfflineCache} "./extensions/emmet"
    configureDependencies ${extensionsExtension-EditingOfflineCache} "./extensions/extension-editing"
    configureDependencies ${extensionsGit-BaseOfflineCache} "./extensions/git-base"
    configureDependencies ${extensionsGitOfflineCache} "./extensions/git"
    configureDependencies ${extensionsGithub-AuthenticationOfflineCache} "./extensions/github-authentication"
    configureDependencies ${extensionsGithubOfflineCache} "./extensions/github"
    configureDependencies ${extensionsGruntOfflineCache} "./extensions/grunt"
    configureDependencies ${extensionsGulpOfflineCache} "./extensions/gulp"
    configureDependencies ${extensionsHtml-Language-FeaturesOfflineCache} "./extensions/html-language-features"
    configureDependencies ${extensionsIpynbOfflineCache} "./extensions/ipynb"
    configureDependencies ${extensionsJakeOfflineCache} "./extensions/jake"
    configureDependencies ${extensionsJson-Language-FeaturesOfflineCache} "./extensions/json-language-features"
    configureDependencies ${extensionsJupyter-AdapterOfflineCache} "./extensions/jupyter-adapter"
    configureDependencies ${extensionsMarkdown-Language-FeaturesOfflineCache} "./extensions/markdown-language-features"
    configureDependencies ${extensionsMarkdown-MathOfflineCache} "./extensions/markdown-math"
    configureDependencies ${extensionsMedia-PreviewOfflineCache} "./extensions/media-preview"
    configureDependencies ${extensionsMerge-ConflictOfflineCache} "./extensions/merge-conflict"
    configureDependencies ${extensionsMicrosoft-AuthenticationOfflineCache} "./extensions/microsoft-authentication"
    configureDependencies ${extensionsNotebook-RenderersOfflineCache} "./extensions/notebook-renderers"
    configureDependencies ${extensionsNPMOfflineCache} "./extensions/npm"
    configureDependencies ${extensionsOpen-Remote-SSHOfflineCache} "./extensions/open-remote-ssh"
    configureDependencies ${extensionsPHP-Language-FeaturesOfflineCache} "./extensions/php-language-features"
    configureDependencies ${extensionsPositron-Code-CellsOfflineCache} "./extensions/positron-code-cells"
    configureDependencies ${extensionsPositron-ConnectionsOfflineCache} "./extensions/positron-connections"
    configureDependencies ${extensionsPositron-JavascriptOfflineCache} "./extensions/positron-javascript"
    configureDependencies ${extensionsPositron-NotebooksOfflineCache} "./extensions/positron-notebooks"
    configureDependencies ${extensionsPositron-ProxyOfflineCache} "./extensions/positron-proxy"
    configureDependencies ${extensionsPositron-PythonOfflineCache} "./extensions/positron-python"
    configureDependencies ${extensionsPositron-ROfflineCache} "./extensions/positron-r"
    configureDependencies ${extensionsPositron-ZedOfflineCache} "./extensions/positron-zed"
    configureDependencies ${extensionsReferences-ViewOfflineCache} "./extensions/references-view"
    configureDependencies ${extensionsSimple-BrowserOfflineCache} "./extensions/simple-browser"
    configureDependencies ${extensionsTunnel-ForwardingOfflineCache} "./extensions/tunnel-forwarding"
    configureDependencies ${extensionsTypescript-Language-FeaturesOfflineCache} "./extensions/typescript-language-features"
    configureDependencies ${extensionsVscode-Api-TestsOfflineCache} "./extensions/vscode-api-tests"
    configureDependencies ${extensionsVscode-Colorize-TestsOfflineCache} "./extensions/vscode-colorize-tests"
    configureDependencies ${extensionsVscode-Test-ResolverOfflineCache} "./extensions/vscode-test-resolver"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn --offline

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
