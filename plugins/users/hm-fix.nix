{ config, lib, pkgs, ... }:
let iceLib = config.icebox.static.lib;
in {
  options.icebox.static.users.hm-fix = with lib;
    mkOption {
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
  config.systemd.services =
    iceLib.functions.mkUserConfigs (n: c: "home-manager-${n}") (n: c: {
      # Hacky workaround of issue 948 of home-manager
      preStart = ''
        ${pkgs.nix}/bin/nix-env -i -E
      '';
    }) config.icebox.static.users.hm-fix;
}
