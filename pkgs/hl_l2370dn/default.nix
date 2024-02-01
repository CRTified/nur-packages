{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, perl
, gnused
, ghostscript
, file
, coreutils
, gnugrep
, which
}:

let
  arches = [ "x86_64" "i686" "armv7l" ];

  runtimeDeps = [
    ghostscript
    file
    gnused
    gnugrep
    coreutils
    which
  ];
in

stdenv.mkDerivation rec {
  pname = "cups-brother-hll2370dn";
  version = "4.0.0-1";

  nativeBuildInputs = [ dpkg makeWrapper autoPatchelfHook ];
  buildInputs = [ perl ];

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103581/hll2370dnpdrv-${version}.i386.deb";
    hash = "sha256-5nOhPe7j6ClBVgZKlEuRZknwSmnq+NiDWmWvo6oJQfc=";
  };

  unpackPhase = "dpkg-deb -x $src .";

  patches = [
    # The brother lpdwrapper uses a temporary file to convey the printer settings.
    # The original settings file will be copied with "400" permissions and the "brprintconflsr3"
    # binary cannot alter the temporary file later on. This fixes the permissions so the can be modified.
    # Since this is all in briefly in the temporary directory of systemd-cups and not accessible by others,
    # it shouldn't be a security concern.
    ./fix-perm.patch
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -ar opt $out/opt
    # delete unnecessary files for the current architecture
  '' + lib.concatMapStrings
    (arch: ''
      echo Deleting files for ${arch}
      rm -r "$out/opt/brother/Printers/HLL2370DN/lpd/${arch}"
    '')
    (builtins.filter (arch: arch != stdenv.hostPlatform.linuxArch) arches) + ''
    # bundled scripts don't understand the arch subdirectories for some reason
    ln -s \
      "$out/opt/brother/Printers/HLL2370DN/lpd/${stdenv.hostPlatform.linuxArch}/"* \
      "$out/opt/brother/Printers/HLL2370DN/lpd/"

    # Fix global references and replace auto discovery mechanism with hardcoded values
    substituteInPlace $out/opt/brother/Printers/HLL2370DN/lpd/lpdfilter \
      --replace "my \$BR_PRT_PATH =" "my \$BR_PRT_PATH = \"$out/opt/brother/Printers/HLL2370DN\"; #" \
      --replace "PRINTER =~" "PRINTER = \"HLL2370DN\"; #"
    substituteInPlace $out/opt/brother/Printers/HLL2370DN/cupswrapper/lpdwrapper \
      --replace "my \$basedir = C" "my \$basedir = \"$out/opt/brother/Printers/HLL2370DN\" ; #" \
      --replace "PRINTER =~" "PRINTER = \"HLL2370DN\"; #"

    # Make sure all executables have the necessary runtime dependencies available
    find "$out" -executable -and -type f | while read file; do
      wrapProgram "$file" --prefix PATH : "${lib.makeBinPath runtimeDeps}"
    done

    # Symlink filter and ppd into a location where CUPS will discover it
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model
    mkdir -p $out/etc/opt/brother/Printers/HLL2370DN/inf

    ln -s $out/opt/brother/Printers/HLL2370DN/inf/brHLL2370DNrc \
          $out/etc/opt/brother/Printers/HLL2370DN/inf/brHLL2370DNrc
    ln -s \
      $out/opt/brother/Printers/HLL2370DN/cupswrapper/lpdwrapper \
      $out/lib/cups/filter/brother_lpdwrapper_HLL2370DN
    ln -s \
      $out/opt/brother/Printers/HLL2370DN/cupswrapper/brother-HLL2370DN-cups-en.ppd \
      $out/share/cups/model/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "http://www.brother.com/";
    description = "Brother HLL2370DN printer driver";
    license = licenses.unfree;
    platforms = builtins.map (arch: "${arch}-linux") arches;
  };
}
