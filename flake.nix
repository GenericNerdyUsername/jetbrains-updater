{
  description = "Automatic updates for jetbrains products";
  outputs = {...}: rec {
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    overlay = (final: prev: {jetbrains = (pkgs final prev.jetbrains.jdk) // {jdk = prev.jetbrains.jdk;};});
    pkgs = source: jdk: source.callPackage ./jetbrains/default.nix {jdk=jdk;};
  };
}
