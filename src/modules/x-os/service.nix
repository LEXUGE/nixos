{ config, pkgs, lib, ... }:

with lib;

let cfg = config.x-os;
in {
  options.x-os = {
    enableVirtualisation = mkOption {
      type = types.bool;
      default = false;
      description =
        "Enable virtualisation toolkit (libvirt, vbox). Contents are subjected to change. Be sure to add users to groups.";
    };
    enableExtraServices = mkOption {
      type = types.bool;
      default = true;
      description =
        "Enable extra services. Disable this would inactivate all other service-related options like enableVirtualisation.";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    ({
      # Enable GVFS, implementing "trash" and so on.
      services.gvfs.enable = true;

      # Don't suspend if lid is closed with computer on power.
      services.logind.lidSwitchExternalPower = "lock";

      # Enable GNU Agent in order to make GnuPG works.
      programs.gnupg.agent.enable = true;

      # Enable sound.
      sound.enable = true;

      # Configuration of pulseaudio to facilitate bluetooth headphones and Steam.
      hardware.pulseaudio = {
        enable = true;
        # 32 bit support for steam.
        support32Bit = true;
        # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
        # Only the full build has Bluetooth support, so it must be selected here.
        package = pkgs.pulseaudioFull;
      };
    })
    (mkIf (cfg.enableExtraServices) (mkMerge [
      ({
        # Enable WireShark
        programs.wireshark = {
          enable = true;
          package = pkgs.wireshark-qt;
        };

        # Enable TRIM Service (May have security concern here)
        services.fstrim.enable = true;

        # Enable usbmuxd for iOS devices.
        services.usbmuxd.enable = true;

        # Enable CUPS to print documents.
        services.printing.enable = true;

        # Libvirtd
        # We DON'T enable it because it uses dnsmasq which blocks clash's binding on 0.0.0.0:53
        # virtualisation.libvirtd.enable = true;
        # FIXME: Should we let users add them to group or other way around.

        # OpenGL 32 bit support for steam
        hardware.opengl.driSupport32Bit = true;

        # Enable fwupd service
        services.fwupd.enable = true;

        # Enable the OpenSSH daemon.
        # services.openssh.enable = true;
      })
      (mkIf (config.std.interface.system.bluetooth.enable) {
        hardware.bluetooth = {
          enable = true;
          disabledPlugins = [ "sap" ];
        };
        # Whether enable blueman or not
        services.blueman.enable =
          mkIf (config.std.interface.system.bluetooth.service == "blueman")
          true;
      })

      (mkIf (cfg.enableVirtualisation) {
        # Enable Vbox
        virtualisation.virtualbox.host.enable = true;
      })
    ]))
  ]);
}
