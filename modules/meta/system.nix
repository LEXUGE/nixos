# This is the module for system wide configuration options

{ lib, ... }:

let
  proxyModule = with lib;
    types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          description =
            "The user who would run the transparent proxy systemd service.";
        };

        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Proxy local server listen address.";
        };

        localPort = mkOption {
          type = types.port;
          default = 1080;
          description =
            "Proxy local server (<literal>ss-local</literal>) listen port";
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
  options.meta.system = with lib; {
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
