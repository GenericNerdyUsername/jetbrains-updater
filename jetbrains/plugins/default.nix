{ fetchurl
, fetchzip
, lib
, stdenv

, delve
, autoPatchelfHook
}:
# These functions do NOT check for plugin compatibility
# Check by installing manually first

# Example usage:
# with pkgs.jetbrains.plugins;
# pluginInfo = getUrl {id="9568"; hash="sha256-...";};
# plugin = urlToDrv (pluginInfo // {hash="sha256-...";});
# editor = addPlugins pkgs.jetbrains.idea-ultimate [ plugin ];
rec {
  addPlugins = ide: plugins: stdenv.mkDerivation {
     pname = ide.pname + lib.optionalString (lib.hasSuffix ide.pname "-with-plugins") "-with-plugins";
     version = ide.version;
     src = ide;
     dontInstall = true;
     dontFixup = true;
     passthru.previous = ide;
     passthru.plugins = plugins ++ (ide.plugins or []);
     newPlugins = plugins;
     buildPhase = let
       pluginCmdsLines = map (plugin: "ln -s ${plugin} \"$out\"/${ide.pname}/plugins/${builtins.baseNameOf plugin}") plugins;
       pluginCmds = builtins.concatStringsSep "\n" pluginCmdsLines;
     in ''
       cp -r ${ide} $out
       chmod +w -R $out
       IFS=' ' read -ra pluginArray <<< "$newPlugins"
       for plugin in "''${pluginArray[@]}"
       do
        ln -s "$plugin" -t $out/$pname/plugins/
       done
       sed "s|${ide.outPath}|$out|" -i $out/bin/$pname
       '';
  };


  urlToDrv = {
    url,
    hash ? "",
    extra ? {},
    name ? "jetbrains-plugin",
    ...
  }: let
    src = if lib.strings.hasSuffix ".jar" url then
      fetchurl { inherit url hash; executable = true;}
    else fetchzip { inherit url hash name; stripRoot = false; extension = ".zip"; executable = true; };
  in
  if extra ? commands then
    stdenv.mkDerivation {
      inherit src name;
      buildInputs = extra.inputs or [];
      buildPhase = ''
      runHook preBuild
      ${extra.commands}
      runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        cp -a . $out
        runHook postInstall
      '';
    }
  else src;

  getUrl = { id, hash ? "", version ? "latest", channel ? "" }: with builtins; rec {
    requestUrl = "https://plugins.jetbrains.com/api/plugins/${toString id}/updates?channel=${channel}";
    fetchurlCall = fetchurl {
      name = "jb-plugin-${toString id}-req";
      url = requestUrl;
      inherit hash;
      postFetch = "sed -e 's/\"compatibleVersions\":{[^}]*},//g' -e 's/\"downloads\":[0-9]+,//g' $out | tee $out";
    };
    resp = fromJSON (readFile fetchurlCall.outPath);
    target = let
      targetVersion = head (filter (x: x.version == version) resp);
      latest = head resp;
    in if version == "latest" then latest else targetVersion;
    url = "https://plugins.jetbrains.com/files/" + target.file;
    extra = specialPlugins."${toString id}" or {};
  };

  # This is a list of plugins that need special treatment. For example, the go plugin (id is 9568) comes with delve, a
  # debugger, but that needs various linking fixes. The changes here replace it with the system one.
  specialPlugins = {
    "9568" = {  # Go
      inputs = [ delve ];
      commands = let
        arch = (if stdenv.isLinux then "linux" else "mac") + (if stdenv.isAarch64 then "arm" else "");
      in "ln -sf ${delve}/bin/dlv lib/dlv/${arch}/dlv";
    };
    "8182" = { # Rust
      inputs = [ autoPatchelfHook ];
      commands = "chmod +x -R bin";
    };
  };
}