{ stdenv
, fetchurl
, dpkg
, lib
, glib
, nss
, nspr
, cups
, dbus
, libdrm
, gtk3
, pango
, cairo
, libxkbcommon
, mesa
, expat
, alsa-lib
, buildFHSEnv
}:

let
  pname = "positron";
  version = "2024.08.0-31";
  src = fetchurl {
    url = "https://github.com/posit-dev/positron/releases/download/${version}/Positron-${version}.deb";
    hash = "sha256-8LckYQ++uv8fOHOBLaPAJfcJM0/Fc6YMKhAsXHFI/nY=";
  };

  positronBase = stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ dpkg ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out $out/bin $out/share
      mv usr/share/* $out/share/
      ln -s $out/share/positron/bin/positron $out/bin/positron
      runHook postInstall
    '';
  };

  positronFHS = buildFHSEnv {
    name = "positron-fhs";
    targetPkgs = pkgs: (with pkgs; [
      positronBase
      udev
      alsa-lib
      glib
      nss
      nspr
      atk
      cups
      dbus
      gtk3
      libdrm
      pango
      cairo
      mesa
      expat
      libxkbcommon
    ]) ++ (with pkgs.xorg; [
      libX11
      libXcursor
      libXrandr
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libxcb
    ]);
    runScript = ''
      positron $*
    '';
  };

in stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ln -s ${positronFHS}/bin/positron-fhs $out/bin/positron
    ln -s ${positronBase}/share/ $out
    runHook postInstall
  '';

  meta = {
    description = "Positron, a next-generation data science IDE";
    longDescription = ''
      Positron is an extensible, polyglot IDE built by Posit PBC.
    '';
    homepage = "https://github.com/posit-dev/positron";
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "positron";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
