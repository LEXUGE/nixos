# This is the module for system wide configuration options

{ lib, ... }:

let
  proxyModule = with lib;
    types.submodule {
      options = {
        clashUserName = mkOption {
          type = types.str;
          default = "clash";
          description =
            "The user who would run the clash proxy systemd service. User would be created automatically.";
        };

        redirPort = mkOption {
          type = types.port;
          default = 1081;
          description =
            "Proxy local redir server (<literal>ss-redir</literal>) listen port";
        };
      };
    };
in {
  options.local.system = with lib; {
    binaryCaches = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Binary caches to use.";
    };
    dpi = mkOption {
      type = types.int;
      default = 96;
      description =
        "Set the default DPi value (under 1080P). These options could be scaled by scale value in share.";
    };

    cursorSize = mkOption {
      type = types.int;
      default = 16;
      description =
        "Set the default cursor size value (under 1080P). These options could be scaled by scale value in share.";
    };
    ibus-engines = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExample "with pkgs.ibus-engines; [ mozc hangul ]";
      description = "List of ibus engines to apply";
    };
    hostname = mkOption {
      type = types.str;
      description = "The hostname of the system";
    };
    proxy = mkOption {
      type = types.nullOr proxyModule;
      default = null;
      description = "Proxy related configurations";
    };
  };
}
