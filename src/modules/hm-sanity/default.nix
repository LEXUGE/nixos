{ config, lib, pkgs, ... }:
with lib;
let cfg = config.hm-sanity;
in {
  options.hm-sanity.users = mkOption {
    type = with types; listOf str;
    default = [ ];
    description = "Names of users to which this fix would apply to";
  };
  config = {
    # Verify that we can connect to the Nix store and/or daemon. This will
    # also create the necessary directories in profiles and gcroots.
    # See also: https://github.com/rycee/home-manager/pull/1246
    systemd.services = builtins.listToAttrs (map (n:
      lib.attrsets.nameValuePair ("home-manager-${n}") ({
        preStart = "${pkgs.nix}/bin/nix-build --expr '{}' --no-out-link";
      })) cfg.users);
  };
}
