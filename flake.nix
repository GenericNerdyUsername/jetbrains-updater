# TODO actually use jcef in jdk compile
# TODO add more stuff to README

{
  description = "Automatic updates for jetbrains products";

  outputs = { nixpkgs, ... }: rec {
    overlay = (final: prev: {
      jcef = final.callPackage ./jcef.nix {};
      jetbrains = final.callPackage ./jetbrains {}
        // { jdk = final.callPackage ./jetbrains-jdk.nix {}; };
    });
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ overlay ]; config.allowUnfree = true; };
    in { jetbrains = pkgs.jetbrains; jcef = pkgs.jcef; };
  };

}
