{ lib
, buildPythonApplication
, buildPythonPackage
, fetchPypi
, fetchurl
, python
, setuptools
, wheel
, alsa-lib
, babel
, bpylist2
, click
, construct
, cryptography
, customtkinter
, exifread
, imagehash
, packaging
, pandas
, paramiko
, pillow
, pyarrow
, pycryptodome
, pymobiledevice3
, tkinter
}:

rec {
  nskeyedunarchiver = buildPythonPackage rec {
    pname = "NSKeyedUnArchiver";
    version = "1.5.2";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-2aLV1I6p4seNMb+/y6l8AnlBkvO0VINC1yfVS90gvro=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    doCheck = false;

    pythonImportsCheck = [ "NSKeyedUnArchiver" ];
  };

  iosbackup = buildPythonPackage rec {
    pname = "iOSbackup";
    version = "0.9.925";
    pyproject = false;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-M1Rakknls/qu3x7ngv5r38y9wPrg3vuhzuM2pl+T0co=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
      nskeyedunarchiver
      pycryptodome
    ];

    prePatch = ''
      substituteInPlace setup.py \
        --replace-fail "from iOSbackup import __version__" "__version__ = \"${version}\""
    '';

    doCheck = false;

    pythonImportsCheck = [ "iOSbackup" ];
  };

  pyiosbackup = buildPythonPackage rec {
    pname = "pyiosbackup";
    version = "0.2.4";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-ELTSoRyb7ck6VGesrT/b4YvC3ENBVpIOciMibtTQvrc=";
    };

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    propagatedBuildInputs = [
      bpylist2
      click
      construct
      cryptography
      packaging
    ];

    doCheck = false;

    pythonImportsCheck = [ "pyiosbackup" ];
  };

  simpleaudio_patched = buildPythonPackage rec {
    pname = "simpleaudio-patched";
    version = "1.0.5";
    pyproject = true;

    src = fetchPypi {
      pname = "simpleaudio_patched";
      inherit version;
      hash = "sha256-802Ox/sXX8BU2EsWQuqOyqT0mg0GYdmIUOxADc/fsAQ=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    buildInputs = [
      alsa-lib
    ];

    doCheck = false;

    pythonImportsCheck = [ "simpleaudio" ];
  };

  tkcalendar = buildPythonPackage rec {
    pname = "tkcalendar";
    version = "1.6.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-8WJWyENvQt2CJ4wDvzfpggNZL6/i7t2C70iPzPoJ+oY=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
      babel
    ];

    doCheck = false;

    pythonImportsCheck = [ "tkcalendar" ];
  };

  crossfiledialog = buildPythonPackage rec {
    pname = "crossfiledialog";
    version = "1.3.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-u1xlTUoNXYIrvnJuTH83Ae9DsW1uMJM4KPXouMLcoa8=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    doCheck = false;

    pythonImportsCheck = [ "crossfiledialog" ];
  };

  pdfme = buildPythonPackage rec {
    pname = "pdfme";
    version = "0.4.12";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-yTBaR+e1hjOVNqO5EP6dZYJ9G4Bg3Xbv0yUcW0K8E2Q=";
    };

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    doCheck = false;

    pythonImportsCheck = [ "pdfme" ];
  };

  ufade = buildPythonApplication rec {
    pname = "ufade";
    version = "1.0.4";
    format = "other";

    src = fetchurl {
      url = "https://github.com/prosch88/UFADE/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-15SOaW1mquiOpI6n1O8CXV6Pb19vRGUE0W1pEzAwXRI=";
    };

    sourceRoot = "UFADE-${version}";

    propagatedBuildInputs = [
      crossfiledialog
      customtkinter
      exifread
      imagehash
      iosbackup
      nskeyedunarchiver
      pandas
      paramiko
      pdfme
      pillow
      pyarrow
      pyiosbackup
      pymobiledevice3
      simpleaudio_patched
      tkcalendar
      tkinter
    ];

    dontBuild = true;
    doCheck = false;

    installPhase = ''
      runHook preInstall

      sitePackages="$out/${python.sitePackages}"
      mkdir -p "$sitePackages" "$out/bin"

      cp -r ufade assets "$sitePackages/"
      install -Dm644 bu_pw.txt "$sitePackages/bu_pw.txt"
      install -Dm755 ufade.py "$sitePackages/ufade.py"

      printf '%s\n' \
        '#!${python.interpreter}' \
        'import runpy' \
        "runpy.run_path(\"$sitePackages/ufade.py\", run_name=\"__main__\")" \
        > "$out/bin/ufade"
      chmod +x "$out/bin/ufade"

      runHook postInstall
    '';

    pythonImportsCheck = [ "ufade" ];

    meta = with lib; {
      description = "Universal Forensic Apple Device Extractor";
      homepage = "https://github.com/prosch88/UFADE";
      license = licenses.gpl3Only;
      mainProgram = "ufade";
      platforms = platforms.linux;
    };
  };
}
