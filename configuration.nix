{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./src/minecraft-server.nix
    ./src/users.nix
    ./src/networking.nix
    ./src/jupyter.nix
  ];

  home-manager.useUserPackages = true;

  std.interface = {
    system = {
      dirs = {
        secrets = {
          clash = "/etc/nixos/secrets/clash.yaml";
          keyfile = "/etc/nixos/secrets/keyfile.bin";
        };
      };
      bluetooth = {
        # Force enable/disable bluetooth
        # enable = true;
        # Choose default bluetooth service
        service = null;
      };
    };
    devices = {
      # resume_offset value. Obtained by <literal>filefrag -v /var/swapFile | awk '{ if($1=="0:"){print $4} }'</literal>
      # If you want to hibernate, you MUST set it properly.
      # swapResumeOffset = 13742080;
    };
  };

  system.stateVersion = "20.09";

  x-os = {
    enable = true;
    enableSwap = false;
    enableVirtualisation = false;
    # Use TUNA (BFSU) Mirror together with original cache because TUNA has better performance inside Mainland China.
    # Set the list to `[ ]` to use official cache only.
    binaryCaches = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
    # Choose ibus engines to apply
    ibus-engines = with pkgs.ibus-engines; [ libpinyin typing-booster ];
    # iwdConfig = { General = { UseDefaultInterface = true; }; };
  };
}
