{
  lib,
  buildPythonPackage,
  cargo,
  fetchFromGitHub,
  pkg-config,
  rustc,
  rustPlatform,
  # Runtime dependencies
  scipy,
  formulaic,
  pandas,
  numba,
  seaborn,
  tabulate,
  tqdm,
  great-tables,
  numpy,
  narwhals,
  jax,
  joblib,
  # Test dependencies
  pytestCheckHook,
  pytest-cov,
  pytest-xdist,
  # R integration dependencies (optional)
  rpy2,
}:

buildPythonPackage rec {
  pname = "pyfixest";
  version = "0.30.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "py-econometrics";
    repo = "pyfixest";
    rev = "v${version}";
    hash = "sha256-xu/CfJ36tPB0GiSFBQcViiOqpm7UiplG6Dc7HPxh420=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-CoeshujI6wk+sWj7Fic0unLg225npOYMyLg8sj6PGmc=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    cargo
    rustc
    pkg-config
  ];

  dependencies = [
    scipy
    formulaic
    pandas
    numba
    seaborn
    tabulate
    tqdm
    great-tables
    numpy
    narwhals
    jax
    joblib
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
    pytest-xdist
  ] ++ lib.optionals (rpy2 != null) [
    rpy2
  ];

# Remove pytestFlagsArray and add custom check phase
dontUsePytestCheckHook = true;

checkPhase = ''
  runHook preCheck

  cd $out/lib/python*/site-packages
  python -m pytest $src/tests/ \
    -n auto \
    -m "not \\(against_r_core or against_r_extended or extended or plots\\)" \
    --ignore=$src/tests/test_i.py \
    --ignore=$src/tests/test_iv.py \
    --ignore=$src/tests/test_vs_fixest.py \
    --ignore=$src/tests/test_plots.py \
    -k "not test_wildboottest and not test_against_r and not test_extended"

  runHook postCheck
'';


  meta = with lib; {
    description = "Fast High-Dimensional Fixed Effects Regression in Python following fixest-syntax";
    homepage = "https://github.com/py-econometrics/pyfixest";
    changelog = "https://github.com/py-econometrics/pyfixest/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ b-rodrigues ];
    platforms = platforms.unix;
  };
}
