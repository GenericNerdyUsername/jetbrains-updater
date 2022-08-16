{
  description = "Automatic updates for jetbrains products";
  outputs = {...}: rec {
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    overlay = (final: prev: {jetbrains = (jetbrains final);});
    jetbrains = pkgs: pkgs.callPackage ./jetbrains {
      jdk = pkgs.jetbrains.jdk;
    } // {
      jdk = pkgs.callPackage ./jetbrains-jdk {};
    };
  };
}
