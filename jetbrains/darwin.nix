{ lib
, stdenvNoCC
, undmg
, ...
}:

{ meta
, pname
, product
, productShort ? product
, src
, version
, plugins ? []
, ...
}:

let
  loname = lib.toLower productShort;
in
  stdenvNoCC.mkDerivation {
    inherit pname meta src version plugins;
    desktopName = product;
    installPhase = ''
      runHook preInstall
      APP_DIR="$out/Applications/${product}.app"
      mkdir -p "$APP_DIR"
      cp -Tr "${product}.app" "$APP_DIR"
      mkdir -p "$out/bin"
      cat << EOF > "$out/bin/${loname}"
      open -na '$APP_DIR' --args "\$@"
      EOF
      chmod +x "$out/bin/${loname}"
      IFS=' ' read -ra pluginArray <<< "$plugins"
      for plugin in "''${pluginArray[@]}"
      do
          ln -s "$plugin" -t $out/$pname/plugins/
      done
      runHook postInstall
    '';
    nativeBuildInputs = [ undmg ];
    sourceRoot = ".";
  }