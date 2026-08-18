{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kalico-plugin-led-effect";
  version = "v0.0.19";

  src = fetchFromGitHub {
    owner = "julianschill";
    repo = "klipper-led_effect";
    rev = finalAttrs.version;
    hash = "sha256-ZGYk1Qdm7GFEiS7xepjqIlo1L/AZZKEEIOWdG9UA+4I=";
  };

  installPhase = ''
    mkdir -p $out/klippy/plugins
    ln -s $src/src/led_effect.py $out/klippy/plugins/led_effect.py
  '';

  passthru.kalicoPlugin = {
    pythonDependencies = _: [];
  };

  meta = {
    description = "LED effects plugin for Kalico";
    homepage = "https://github.com/julianschill/klipper-led_effect";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
