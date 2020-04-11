{ pkgs, config, lib, ... }:

let
  inherit (pkgs) gnugrep iptables clash;
  inherit (lib) optionalString mkIf;
  cfg = config.local.system;
  clashGroupName = "clash-group";
  clashUserName = "clash";
  redirProxyPortStr = toString cfg.proxy.redirPort;

  # Run iptables 4 and 6 together.
  helper = ''
    ip46tables() {
      ${iptables}/bin/iptables -w "$@"
      ${
        optionalString config.networking.enableIPv6 ''
          ${iptables}/bin/ip6tables -w "$@"
        ''
      }
    }
  '';

  configPath = toString (config.local.share.dirs.secrets + /clash.yaml);
  tag = "CLASH_SPEC";

in mkIf (cfg.proxy != null) {
  environment.etc."clash/Country.mmdb".source =
    "${pkgs.maxmind-geoip}/Country.mmdb"; # Bring pre-installed geoip data into directory.
  environment.etc."clash/config.yaml".source = configPath;

  users.groups.${clashGroupName} = { };
  users.users.${clashUserName} = {
    description = "Clash deamon user";
    group = clashGroupName;
    isSystemUser = true;
  };

  systemd.services.clash = let
    # Delete the chain to avoid unnecessary incident.
    # ip46tables -t nat -F ${tag} 2>/dev/null || true

    # Create a new chain appending at the end.
    # ip46tables -t nat -N ${tag} 2>/dev/null || true

    # Don't forward pkts with creator in this group. Since after forwarding by clash the packets' owner would be the one in group, this helps us to avoid dead loop in packet forwarding.
    # ip46tables -t nat -A ${tag} -m owner --gid-owner ${clashGroupName} -j RETURN 2>/dev/null || true

    # Forward all TCP traffic to the redir port of Clash.
    # ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

    # For all TCP traffic on OUTPUT chain, put them into our newly created chain.
    # ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    preStartScript = pkgs.writeShellScript "clash-prestart" ''
      ${helper}
      ip46tables -t nat -F ${tag} 2>/dev/null || true
      ip46tables -t nat -N ${tag} 2>/dev/null || true
      ip46tables -t nat -A ${tag} -m owner --gid-owner ${clashGroupName} -j RETURN 2>/dev/null || true
      ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

      ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    '';

    postStopScript = pkgs.writeShellScript "clash-poststop" ''
      ${iptables}/bin/iptables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/iptables-restore -c
      ${optionalString config.networking.enableIPv6 ''
        ${iptables}/bin/ip6tables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/ip6tables-restore -c
      ''}
    '';
  in {
    description = "Clash networking service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script =
      "exec ${clash}/bin/clash -d /etc/clash"; # We don't need to worry about whether /etc/clash is reachable in Live CD or not. Since it would never be execuated inside LiveCD.

    # Don't start if the config file doesn't exist.
    unitConfig = { ConditionPathExists = configPath; };
    serviceConfig = {
      ExecStartPre =
        "+${preStartScript}"; # Use prefix `+` to run iptables as root/
      ExecStopPost = "+${postStopScript}";
      # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
      # CAP_NET_ADMIN: Listen on UDP.
      AmbientCapabilities =
        "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
      User = clashUserName;
      Group = clashGroupName;
      Restart = "on-failure";
    };
  };
}
