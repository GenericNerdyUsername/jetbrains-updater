{
  description = "Automatic updates for jetbrains products";
  outputs = {...}: rec {
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    overlay = (final: prev: {jetbrains = (pkgs final) // {jdk = prev.jetbrains.jdk;};});
    pkgs = source: source.callPackage ./jetbrains/default.nix;
  };
}
