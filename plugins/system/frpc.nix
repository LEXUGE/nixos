{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.icebox.static.system.frpc;
  frpcConfigFile =
    pkgs.writeText "frpc.ini" (generators.toINI { } cfg.frpcConfig);
in {
  options.icebox.static.system.frpc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable frp client service";
    };
    frpcConfig = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [ bool int str ]));
      description = "frpc.ini config file";
      default = { };
    };
  };

  config = mkIf (cfg.enable) {
    users.users.frpc = {
      description = "frp client service user";
      isSystemUser = true;
    };

    systemd.services.frpc = {
      description = "frp client service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.frp}/bin/frpc -c ${frpcConfigFile}";
        User = "frpc";
      };
    };
  };
}
