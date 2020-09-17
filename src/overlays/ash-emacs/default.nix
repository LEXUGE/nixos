{ nixos, emacs-overlay, flake-utils }:

with nixos.lib;

let
  concatEmacsConfig = dir:
    foldl (a: b: a + b) ""
    (attrsets.mapAttrsToList (n: v: "${builtins.readFile (dir + "/${n}")}")
      (builtins.readDir dir));
  importer = system:
    (import nixos {
      system = system;
      overlays = [ emacs-overlay.overlay ];
    });
in (final: prev:
  builtins.listToAttrs (map (system:
    attrsets.nameValuePair ("ash-emacs-${system}")
    ((importer system).emacsWithPackagesFromUsePackage {
      config = concatEmacsConfig ../../../dotfiles/ash/emacs.d/elisp;
      package = (importer system).pkgs.emacsGcc;
      alwaysEnsure = true;
    })) flake-utils.lib.defaultSystems))
