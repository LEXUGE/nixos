{
  description = "Harry Ying's NixOS configuration";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    home = {
      url = "github:rycee/home-manager/bqv-flakes";
      inputs.nixpkgs.follows = "nixos";
    };
    netkit.url = "github:icebox-nix/netkit.nix";
    std.url = "github:icebox-nix/std";
  };

  outputs = { self, nixos, home, std, netkit }@inputs: {
    nixosModules = {
      ash-profile = (import ./modules/ash-profile);
      x-os = (import ./modules/x-os);
    };
    nixosConfigurations.x1c7 = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./src/devices/x1c7
        std.nixosModule
        self.nixosModules.x-os
        self.nixosModules.ash-profile
        home.nixosModules.home-manager
        netkit.nixosModules.clash
        netkit.nixosModules.wifi-relay
        netkit.nixosModules.minecraft-server
        netkit.nixosModules.frpc
        # FIXME: Currently, nixos-generate-config by defualt writes out modulePath which is unsupported by flake.
        # FIXME: This means on installation, we need to MANUALLY edit the generated hardware-configuration.nix
        nixos.nixosModules.notDetected
      ];
    };
  };
}
