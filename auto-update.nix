{ pkgs, ... }: {
  systemd.services.nixos-update = {
    description = "NixOS Update";
    serviceConfig.Type = "oneshot";
    script = ''
      # Using su is more faultless than trying to reproduce the environment in
      # the way how it implemented in nixos/modules/tasks/auto-upgrade.nix
      ${pkgs.su}/bin/su root -c 'nix-channel --update'
      ${pkgs.su}/bin/su root -c 'NIXOS_LABEL=auto-update nixos-rebuild boot --upgrade'
    '';
  };

  systemd.timers.nixos-update = {
    description = "Run NixOS Update 30m after the start and then every 6h";
    timerConfig.OnBootSec = "30m";
    timerConfig.OnUnitInactiveSec = "6h";
    timerConfig.Unit = "nixos-update.service";
    wantedBy = [ "timers.target" ];
  };
}
