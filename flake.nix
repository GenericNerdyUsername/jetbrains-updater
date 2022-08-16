{
  description = "Automatic updates for jetbrains products";
  outputs = {...}: rec {
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    overlay = (final: prev: {jetbrains = (pkgs final) // {jdk = prev.jetbrains.jdk;};});
    pkgs = source: import ./jetbrains/default.nix {
      fetchurl = source.fetchurl;
      lib = source.lib;
      stdenv = source.stdenv;
      callPackage = source.callPackage;
      jdk = source.jetbrains.jdk;
      cmake = source.cmake;
      gdb = source.gdb;
      zlib = source.zlib;
      python3 = source.python3;
      dotnet-sdk_6 = source.dotnet-sdk_6;
      maven = source.maven;
      autoPatchelfHook = source.autoPatchelfHook;
      libdbusmenu = source.libdbusmenu;
    };
  };
}
