{
  lib,
  buildPythonPackage,
  poetry-core,
  fetchPypi,
  msgspec,
  numpy,
  pandas,
  pydantic,
  scikit-learn,
  scipy,
  toolz
}:

buildPythonPackage rec {

  pname = "saiph";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-+qwiLP+uac9PPyZ0wYs4WbDRSaS77nRqS2PazZvjTug=";
  };

  format = "pyproject";

  build-system = [
    poetry-core
  ];

  propagatedBuildInputs = [
    msgspec
    numpy
    pandas
    pydantic
    scikit-learn
    scipy
    toolz
  ];

  meta = with lib; {
    description = "A projection package";
    homepage = "https://github.com/octopize/saiph/tree/main";
    license = licenses.asl20;
    maintainers = with maintainers; [ b-rodrigues ];
  };
}
