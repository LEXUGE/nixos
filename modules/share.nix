{ config, lib, ... }:
with lib;

let cfg = config.share;
in {
  options.share = {
    scale = mkOption {
      type = types.int;
      default = 1;
      description = "";
    };
  };
}
