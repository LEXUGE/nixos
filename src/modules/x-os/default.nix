{ ... }: {
  imports = [
    ./boot.nix
    ./general.nix
    ./desktop.nix
    ./i18n.nix
    ./networking.nix
    ./packages.nix
    ./service.nix
    ./security.nix
  ];
}
