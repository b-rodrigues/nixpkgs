{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
  anndata,
  h5py,
  jax,
  jaxlib,
  lightning,
  mudata,
  numpy,
  pyro-ppl,
  rich,
  scikit-learn,
  scipy,
  seaborn,
  torch,
  torchmetrics,
  tuna,
  pytest,
  ruff,
  mypy,
  pre-commit,
  flit,
}:

buildPythonPackage rec {
  pname = "scvi-tools";
  version = "1.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "scverse";
    repo = "scvi-tools";
    rev = "refs/tags/${version}";
    hash = "";
  };

  nativeBuildInputs = [
    flit
  ];

  propagatedBuildInputs = [
    anndata
    h5py
    jax
    jaxlib
    lightning
    mudata
    numpy
    pyro-ppl
    rich
    scikit-learn
    scipy
    seaborn
    torch
    torchmetrics
    tuna
  ];

  nativeCheckInputs = [
    pytest
    ruff
    mypy
    pre-commit
  ];

  pythonImportsCheck = [ "scvi" ];

  meta = with lib; {
    description = "Deep probabilistic analysis of single-cell omics data";
    homepage = "https://github.com/scverse/scvi-tools";
    license = licenses.mit;
    maintainers = with maintainers; [ your-github-handle ]; # Replace with your handle
  };
}
