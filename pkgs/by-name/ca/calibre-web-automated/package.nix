{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      sqlalchemy = super.sqlalchemy_1_4;
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "calibre-web-automated";
  version = "2.1.2";

  pyproject = false;
  dontBuild = true;

  srcs = [
    (fetchFromGitHub {
      name = "cw-automated";
      owner = "crocodilestick";
      repo = "Calibre-Web-Automated";
      rev = "V${version}";
      hash = "sha256-NruRMsUCugvXE/zR9tIKhDACvKIiOjTCPLbhhvYrPvc=";
    })
    (fetchFromGitHub {
      name = "calibre-web";
      owner = "janeczku";
      repo = "calibre-web";
      rev = "0.6.22";
      hash = "sha256-nWZmDasBH+DW/+Cvw510mOv11CXorRnoBwNFpoKPErY=";
    })
  ];

  sourceRoot = ".";

  patches = [
    # These are taken from the calibre-web package
    # default-logger.patch switches default logger to /dev/stdout. Otherwise calibre-web tries to open a file relative
    # to its location, which can't be done as the store is read-only. Log file location can later be configured using UI
    # if needed.
    ./default-logger.patch
  ];

  propagatedBuildInputs = with python.pkgs; [
    advocate
    apscheduler
    babel
    bleach
    chardet
    flask
    flask-babel
    flask-limiter
    flask-login
    flask-principal
    flask-wtf
    iso-639
    jsonschema
    lxml
    pypdf
    python-magic
    pytz
    regex
    requests
    sqlalchemy
    tornado
    unidecode
    wand
    werkzeug
  ];

  postInstall = ''
    mkdir -p $out/app/calibre-web
    mkdir -p $out/app/calibre-web-automated
    mkdir -p $out/bin/

    cp -r calibre-web/* $out/app/calibre-web
    cp -r cw-automated/root/app $out/
    cp -r cw-automated/{scripts,empty_library} $out/app/calibre-web-automated

    echo "--- WEB ---"
    ls $out/app/calibre-web
    echo "---- AUTO ----"
    ls $out/app/calibre-web-automated
    ls $out/app/calibre-web-automated/scripts

    substituteInPlace $out/app/calibre-web-automated/scripts/auto-library.py \
      --replace-warn /app/calibre-web-automated/dirs.json /var/lib/calibre-web-automated/dirs.json \
      --replace-warn /config /var/lib/calibre-web-automated/config \
      --replace-warn /calibre-library /var/lib/calibre-web-automated/library \
      --replace-warn /app/calibre-web-automated $out/calibre-web-automated

    for file in $out/app/calibre-web-automated/scripts/*.py; do
      makeWrapper \
        ${python.interpreter} \
        $out/bin/$(basename "$file" .py) \
        --add-flags "$(basename "$file" .py).py" \
        --chdir $out/app/calibre-web-automated/scripts \
        --prefix PYTHONPATH : "$PYTHONPATH"
    done

    makeWrapper \
      ${python.interpreter} \
      $out/bin/calibre-web-automated \
      --add-flags cps.py \
      --chdir $out/app/calibre-web \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  # Upstream repo doesn't provide any tests.
  doCheck = false;

  meta = with lib; {
    description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
    homepage = "https://github.com/janeczku/calibre-web";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ pborzenkov ];
    platforms = platforms.all;
    mainProgram = "calibre-web";
  };
}
