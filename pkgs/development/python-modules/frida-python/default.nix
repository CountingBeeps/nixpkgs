{
  lib,
  stdenv,
  fetchurl,
  fetchPypi,
  buildPythonPackage,
  typing-extensions,
  darwin,
}:
let
  version = "16.1.4";
  format = "setuptools";

  devkit =
    {
      aarch64-darwin = fetchurl {
        url = "https://github.com/frida/frida/releases/download/${version}/frida-core-devkit-${version}-macos-arm64.tar.xz";
        hash = "sha256-a9YsEbGJraP/gqYzc5EeWzacgZEqwcDFixapBqqhQlI=";
      };

      x86_64-linux = fetchurl {
        url = "https://github.com/frida/frida/releases/download/${version}/frida-core-devkit-${version}-linux-x86_64.tar.xz";
        hash = "sha256-C0PyBNpofSWahOA3Te+LJECar0QUsr4kvIKVS9NMIRE=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
buildPythonPackage rec {
  pname = "frida-python";
  inherit version;

  src = fetchPypi {
    pname = "frida";
    inherit version;
    hash = "sha256-stOiL4QizZN57io8qHDlDNsXBs+ki+lYe/g11j5R5YI=";
  };

  postPatch = ''
    mkdir assets
    pushd assets
    tar xvf ${devkit}
    export FRIDA_CORE_DEVKIT=$PWD
    popd
  '';

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-framework AppKit";

  propagatedBuildInputs = [ typing-extensions ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
  ];

  pythonImportsCheck = [ "frida" ];

  passthru = {
    inherit devkit;
  };

  meta = {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (Python bindings)";
    homepage = "https://www.frida.re";
    license = lib.licenses.wxWindows;
    maintainers = with lib.maintainers; [ s1341 ];
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  };
}
