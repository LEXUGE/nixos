{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./src/minecraft-server.nix
    ./src/users.nix
    ./src/networking.nix
  ];

  home-manager.useUserPackages = true;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  std = {
    system = {
      # Path to directories (always use absolute path to avoid trouble in nixos-install, because we will copy the whole configuration to the same folder under LiveCD).
      # If you don't understand, just keep it as it is.
      dirs = {
        secrets = ./secrets; # Did you read the comments above?
        dotfiles = ./dotfiles;
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
      swapResumeOffset = 13742080;
    };
  };

  system.stateVersion = "19.09";

  x-os = {
    enable = true;
    # Use TUNA (BFSU) Mirror together with original cache because TUNA has better performance inside Mainland China.
    # Set the list to `[ ]` to use official cache only.
    binaryCaches = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
    # Choose ibus engines to apply
    ibus-engines = with pkgs.ibus-engines; [ libpinyin ];
    # iwdConfig = { General = { UseDefaultInterface = true; }; };
  };
}
