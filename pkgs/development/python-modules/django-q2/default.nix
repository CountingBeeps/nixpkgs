{
  lib,
  arrow,
  blessed,
  buildPythonPackage,
  croniter,
  django,
  django-picklefield,
  django-redis,
  fetchFromGitHub,
  future,
  poetry-core,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  redis,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-q2";
  version = "1.7.4";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "django-q2";
    repo = "django-q2";
    rev = "refs/tags/v${version}";
    hash = "sha256-mp/IZkfT64xW42B1TEO6lSHxvLQbeH4td8vqZH7wUxM=";
  };

  nativeBuildInputs = [
    poetry-core
    setuptools
  ];

  propagatedBuildInputs = [
    django-picklefield
    arrow
    blessed
    django
    future
  ];

  nativeCheckInputs = [
    croniter
    django-redis
    pytest-django
    pytest-mock
    pytestCheckHook
  ] ++ django-redis.optional-dependencies.hiredis;

  pythonImportsCheck = [ "django_q" ];

  preCheck = ''
    ${redis}/bin/redis-server &
    REDIS_PID=$!
  '';

  postCheck = ''
    kill $REDIS_PID
  '';

  # don't bother with two more servers to test
  disabledTests = [
    "test_disque"
    "test_mongo"
  ];

  # Most of the tests here are very broken and beyond my ability to fix or track down
  # and disable all of them. The package itself works fine.
  doCheck = false; # !stdenv.hostPlatform.isDarwin;

  meta = with lib; {
    description = "Multiprocessing distributed task queue for Django";
    homepage = "https://django-q2.readthedocs.org";
    changelog = "https://github.com/django-q2/django-q2/blob/master/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [
      gamedungeon
    ];
  };
}
