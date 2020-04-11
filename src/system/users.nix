# Configuratoin dedicated to system users and groups.

{ config, lib, ... }:
let inherit (config.local.system.proxy) clashUserName;
in {
  # Here we should ONLY manage system users but not normal users.
  users = {
    mutableUsers = false;
    users = {
      ${clashUserName} = {
        description = "Clash deamon user";
        isSystemUser = true;
      };
    };
  };
}
