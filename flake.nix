{
  description = "Harry Ying's NixOS configuration";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/gnome-40";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
    };
    # We may have multiple flakes using std, but we only may use one version of std. So we declare it here and let others which depend on it follow.
    std.url = "github:icebox-nix/std";
    #url = "/home/ash/Documents/git/netkit.nix";
    netkit.url = "github:icebox-nix/netkit.nix";
    dcompass.url = "github:LEXUGE/dcompass";
    nixos-cn.url = "github:nixos-cn/flakes";
    #ash-emacs.url = "/home/ash/Documents/git/emacs.d";
    ash-emacs.url = "github:LEXUGE/emacs.d";
    iceberg.url = "github:icebox-nix/iceberg";
    nix-dram.url = "github:dramforever/nix-dram";
  };

  outputs = { self, nixos, home, std, netkit, ash-emacs, iceberg, nixos-cn
    , nix-dram, dcompass, ... }@inputs: {
      x1c7-toplevel =
        self.nixosConfigurations.x1c7.config.system.build.toplevel;
      niximg = self.nixosConfigurations.niximg.config.system.build.isoImage;

      nixosModules = {
        ash-profile = (import ./src/modules/ash-profile);
        x-os = (import ./src/modules/x-os);
      };

      nixosConfigurations = {
        x1c7 = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              x-os.publicKeys = [
                dcompass.publicKey
                netkit.publicKey
                "dram.cachix.org-1:baoy1SXpwYdKbqdTbfKGTKauDDeDlHhUpC+QuuILEMY="
              ];
              nixpkgs.overlays = [
                ash-emacs.overlay
                iceberg.overlay
                nixos-cn.overlay
                dcompass.overlay
                nix-dram.overlay
              ];
            }
            ./configuration.nix
            ./src/devices/x1c7
            std.nixosModule
            self.nixosModules.x-os
            self.nixosModules.ash-profile
            home.nixosModules.home-manager
            netkit.nixosModule
            iceberg.nixosModules.wolfram-jupyter
            # FIXME: Currently, nixos-generate-config by defualt writes out modulePath which is unsupported by flake.
            # FIXME: This means on installation, we need to MANUALLY edit the generated hardware-configuration.nix
            # COMMENT: Seems like it is causing no problem.
            nixos.nixosModules.notDetected
          ];
        };
        niximg = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
            {
              nixpkgs.overlays =
                [ ash-emacs.overlay dcompass.overlay nix-dram.overlay ];
              x-os.publicKeys = [ dcompass.publicKey netkit.publicKey ];
            }
            ./niximg.nix
            std.nixosModule
            self.nixosModules.x-os
            self.nixosModules.ash-profile
            home.nixosModules.home-manager
            netkit.nixosModule
          ];
        };
      };
    };
}
