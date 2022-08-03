## What is this?

This is a nixpkgs overlay in flake format, automatically updated daily. It gives the latest versions of the various jetbrains IDEs.

As most of the code in this repo is copied from `<nixos/nixpkgs>/pkgs/applications/editors/jetbrains`, it has the same license (MIT).

## How do I use it?

Be aware, this is a thing I'm making for personal use. As such, there is basically no testing other than making it work on my machine.

Add to inputs: `jetbrains-updater.url = "gitlab:genericnerdyusername/jetbrains-updater";`

then pick one of:

 - As a package: `environment.systemPackages = [ jetbrains-updater.pkgs.pycharm-community ];`

 - As an overlay: `nixpkgs.overlays = [ jetbrains-updater.overlay ];`

 - As an overlay, prepackaged into a module:
 ```
nixosConfigurations.nixos = {
  system = "x86_64-linux";
  modules = [
    jetbrains-updater.nixosModules.jetbrains-updater
  ];
}
```
