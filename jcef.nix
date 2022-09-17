{ fetchFromGitHub
, fetchurl
, fetchzip
, stdenv
, cmake
, python
, jdk
, git
, libcef
, rsync
, lib

, glib
, nss
, nspr
, atk
, at-spi2-atk
, libdrm
, expat
, libxcb
, libxkbcommon
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, mesa
, gtk3
, pango
, cairo
, alsa-lib
, dbus
, at-spi2-core
, cups
, libxshmfence
}:

assert !stdenv.isDarwin;
# I can't test darwin

let rpath = lib.makeLibraryPath [
  glib
  nss
  nspr
  atk
  at-spi2-atk
  libdrm
  expat
  libxcb
  libxkbcommon
  libX11
  libXcomposite
  libXdamage
  libXext
  libXfixes
  libXrandr
  mesa
  gtk3
  pango
  cairo
  alsa-lib
  dbus
  at-spi2-core
  cups
  libxshmfence
];

in stdenv.mkDerivation rec {
  pname = "jcef";
  version = "0cdd84c";

  nativeBuildInputs = [ cmake python jdk git rsync ];
  buildInputs = [ libX11 ];

  src = fetchFromGitHub {
    owner = "ChromiumEmbedded";
    repo = "java-cef";
    rev = version;
    hash = "sha256-AO/yIKwgHkzUG14cmDIRVjxcb94ws8Ryu6wfur/sPvo=";
    leaveDotGit = true;
  };
  cef-bin = fetchzip rec {
    name = "cef_binary_105.3.36+g88e0038+chromium-105.0.5195.102_linux64";
    url = "https://cef-builds.spotifycdn.com/${name}.tar.bz2";
    hash = "sha256-SEeyFqH+zOeqb9+MNHJ85jA2VaAbsL52tA0KDA2QdXU=";
  }; 
  clang-fmt = fetchurl {
    url = "https://storage.googleapis.com/chromium-clang-format/942fc8b1789144b8071d3fc03ff0fcbe1cf81ac8";
    hash = "sha256-5iAU49tQmLS7zkS+6iGT+6SEdERRo1RkyRpiRvc9nVY=";
  };

  configurePhase = ''
  runHook preConfigure

  patchShebangs tools

  cp -r ${cef-bin} third_party/cef/${cef-bin.name}
  chmod +w -R third_party/cef/${cef-bin.name}
  mkdir -p third_party/cef/${cef-bin.name}/Release/
  patchelf --set-rpath "${rpath}" third_party/cef/${cef-bin.name}/Release/libcef.so
#  cp -f ${libcef}/lib/libcef.so third_party/cef/${cef-bin.name}/Release/libcef.so
#  cp -f ${libcef}/lib/libcef.so third_party/cef/${cef-bin.name}/Release/libcef.so

  cp ${clang-fmt} tools/buildtools/linux64/clang-format
  chmod +w tools/buildtools/linux64/clang-format

  mkdir jcef_build
  cd jcef_build

  cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..

  runHook postConfigure
  '';

  postBuild = "../tools/compile.sh linux64 && ../tools/make_distrib.sh linux64";
  installPhase = "mv ../binary_distrib $out";

  # Tests require a display and I can't figure out how to set that up
  doCheck = false;
  checkPhase = "../tools/run.sh linux64 Release detailed";
}
