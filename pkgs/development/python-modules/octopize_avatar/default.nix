{
  lib,
  buildPythonPackage,
  poetry-core,
  fetchPypi,
  clevercsv,
  httpx,
  numpy,
  pandas,
  pyarrow,
  pydantic,
  structlog,
  tenacity,
  toolz
}:

buildPythonPackage rec {

  pname = "octopize_avatar";
  version = "0.15.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-sphnp8XS6aEjTUgG8bZxzQ+rmC6x8EnQZvMbdQdaMDs=";
  };

  format = "pyproject";

  build-system = [
    poetry-core
  ];

  propagatedBuildInputs = [
    clevercsv
    httpx
    numpy
    pandas
    pyarrow
    pydantic
    structlog
    tenacity
    toolz
  ];

  meta = with lib; {
    description = "Python Interface for Octopize's Avatarization Engine";
    homepage = "https://github.com/octopize/avatar-python";
    license = licenses.asl20;
    maintainers = with maintainers; [ b-rodrigues ];
  };
}
