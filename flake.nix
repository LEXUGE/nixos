{
  description = "Harry Ying's NixOS configuration";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    home = {
      url = "github:nix-community/home-manager/bqv-flakes";
      inputs.nixpkgs.follows = "nixos";
    };
    netkit.url = "github:icebox-nix/netkit.nix";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixos, home, netkit, emacs-overlay, flake-utils }@inputs: {
    x1c7-toplevel = self.nixosConfigurations.x1c7.config.system.build.toplevel;
    niximg = self.nixosConfigurations.niximg.config.system.build.isoImage;

    overlays.ash-emacs = (import ./src/overlays/ash-emacs {
      inherit nixos emacs-overlay flake-utils;
    });

    nixosModules = {
      ash-profile = (import ./src/modules/ash-profile);
      x-os = (import ./src/modules/x-os);
      hm-sanity = (import ./src/modules/hm-sanity);
    };

    nixosConfigurations = {
      x1c7 = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ self.overlays.ash-emacs ]; }
          ./configuration.nix
          ./src/devices/x1c7
          netkit.inputs.std.nixosModule
          self.nixosModules.x-os
          self.nixosModules.ash-profile
          self.nixosModules.hm-sanity
          home.nixosModules.home-manager
          netkit.nixosModules.clash
          netkit.nixosModules.wifi-relay
          netkit.nixosModules.minecraft-server
          netkit.nixosModules.frpc
          netkit.nixosModules.snapdrop
          # FIXME: Currently, nixos-generate-config by defualt writes out modulePath which is unsupported by flake.
          # FIXME: This means on installation, we need to MANUALLY edit the generated hardware-configuration.nix
          nixos.nixosModules.notDetected
        ];
      };
      niximg = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          { nixpkgs.overlays = [ self.overlays.ash-emacs ]; }
          ./niximg.nix
          netkit.inputs.std.nixosModule
          self.nixosModules.x-os
          self.nixosModules.ash-profile
          self.nixosModules.hm-sanity
          home.nixosModules.home-manager
          netkit.nixosModules.clash
        ];
      };
    };
  };
}
