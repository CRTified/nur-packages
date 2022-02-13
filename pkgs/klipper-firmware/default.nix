{ stdenvNoCC, lib, klipper, bintools-unwrapped, gcc-arm-embedded, gnumake
, libffi, libusb, python2, fw_config ? ./skr_e3_dip.config }:
stdenvNoCC.mkDerivation rec {
  name = "klipper-firmware-${version}";
  version = klipper.version;

  src = klipper.src;

  nativeBuildInputs = [
    fw_config
    bintools-unwrapped
    gcc-arm-embedded
    gnumake
    libffi
    libusb
    python2
  ];

  makeFlags = let cprefix = "arm-none-eabi-";
  in [
    "V=1"
    "CROSS_PREFIX=${cprefix}"
    "CPP=${cprefix}cpp"
    "KCONFIG_CONFIG=${fw_config}"
  ];

  installPhase = ''
    mkdir -p $out
    cp ${fw_config} $out/config
    cp out/klipper* $out/
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = {
    inherit (klipper.meta) description homepage license;
    platforms = lib.platforms.all;
  };
}
