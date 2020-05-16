{ config, lib, pkgs, ... }:
let
  iceLib = config.icebox.static.lib;
  cfg = config.icebox.static.users.hm-fix;
in {
  options.icebox.static.users.hm-fix = with lib;
    mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption
            "the Desktop Environment falovored by ash"; # If this is off, nothing should be configured at all.

          configs = mkOption {
            type = with types;
              attrsOf (submodule {
                options.enable = mkOption {
                  type = types.bool;
                  default = true;
                  description =
                    "Whether to enable a (hacky) patch plugin for home-manager issue #948.";
                };
              });
            default = { };
          };
        };
      };
      default = { };
    };
  config.systemd.services =
    iceLib.functions.mkUserConfigs (n: c: "home-manager-${n}") (n: c: {
      # Hacky workaround of issue 948 of home-manager
      preStart = ''
        ${pkgs.nix}/bin/nix-env -i -E
      '';
    }) cfg;
}
