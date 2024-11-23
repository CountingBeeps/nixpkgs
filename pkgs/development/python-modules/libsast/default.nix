{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,

  requests,
  pyyaml,
  billiard,
}:

buildPythonPackage rec {
  pname = "libsast";
  version = "3.1.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ajinabraham";
    repo = "libsast";
    rev = "refs/tags/${version}";
    hash = "sha256-A02VcSgd58m7ZomvAz0TBEe8hRZhx29jAjYl48fwPKg=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    requests
    pyyaml
    billiard
  ];

  pythonImportsCheck = [ "libsast" ];

  meta = {
    description = "Generic SAST for Security Engineers. Powered by regex based pattern matcher and semantic aware semgrep";
    homepage = "https://github.com/ajinabraham/libsast";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ gamedungeon ];
  };
}
