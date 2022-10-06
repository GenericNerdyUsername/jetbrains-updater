# TODO add more stuff to README

{
  description = "Automatic updates for jetbrains products";

  outputs = { nixpkgs, ... }: rec {
    overlay = (final: prev: {
      jetbrains = final.callPackage ./jetbrains { jdk = final.jetbrains.jdk; }
        // { jdk = final.callPackage ./jetbrains-jdk.nix {}; };
    });
    nixosModules.jetbrains-updater.nixpkgs.overlays = [ overlay ];
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ overlay ]; config.allowUnfree = true; };
    in { jetbrains = pkgs.jetbrains; jcef = pkgs.jcef; };
  };

}
