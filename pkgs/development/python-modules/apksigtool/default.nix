{
  lib,
  fetchFromGitHub,
  buildPythonPackage,

  asn1crypto,
  click,
  apksigcopier,
  cryptography,
}:

buildPythonPackage rec {
  pname = "apksigtool";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "obfusk";
    repo = "apksigtool";
    rev = "refs/tags/v${version}";
    hash = "sha256-22dQLH9iMy+UqC90fGZ0STpU55+922SzQTR+dztl6R8=";
  };

  dependencies = [
    asn1crypto
    apksigcopier
    click
    cryptography
  ];

  pythonImportsCheck = [ "apksigtool" ];

  meta = {
    description = "Parse android APK Signing Blocks and verify APK signatures";
    homepage = "https://github.com/obfusk/apksigtool/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ gamedungeon ];
  };
}
