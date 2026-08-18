{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  makeWrapper,

  plugins ? [],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kalico";
  version = "v2026.08.00";

  src = fetchFromGitHub {
    owner = "KalicoCrew";
    repo = "kalico";
    rev = finalAttrs.version;
    hash = "sha256-27QyFFo3YdLhJsVSobw7cjRr1gLPTOcbAWtf1+nEkxM=";
  };

  pythonEnv = python3.withPackages (ps:
    with ps; [
      cffi
      greenlet
      jinja2
      markupsafe
      numpy
      pyserial
      python-can
    ]
    ++ lib.concatMap
      (p: p.kalicoPlugin.pythonDependencies ps)
      plugins
  );

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/klippy $out/config $out/scripts
    cp -r klippy/. $out/klippy/
    cp -r config/. $out/config/
    cp -r scripts/. $out/scripts/

    mkdir -p $out/klippy/plugins

    ${lib.concatMapStringsSep "\n" (p: ''
      for entry in ${p}/klippy/plugins/*; do
        [ -e "$entry" ] || continue
        ln -s "$entry" "$out/klippy/plugins/"
      done
    '') plugins}

    mkdir -p $out/bin
    makeWrapper ${finalAttrs.pythonEnv.interpreter} $out/bin/klippy \
      --add-flags "$out/klippy/klippy.py"
  '';

  meta = {
    homepage = "https://github.com/KalicoCrew/kalico";
    description = "Klipper fork with additional features";
    license = lib.licenses.gpl3Only;
    mainProgram = "klippy";
  };
})
