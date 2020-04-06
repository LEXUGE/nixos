{ pkgs, config, lib, ... }:

let
  inherit (pkgs) gnugrep iptables clash;
  inherit (lib) optionalString mkIf;
  cfg = config.local.system;
  socksGroupName = "clash";
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
  tag = "CLASH_SPEC_ASH";

in mkIf (cfg.proxy != null) {

  users.groups.${socksGroupName} = { };

  systemd.services.clash = {
    description = "Clash networking service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    # FIXME: run under root. Some security implications may apply.
    script = "${clash}/bin/clash -f ${configPath}";

    # Delete the chain to avoid unnecessary incident.
    # ip46tables -t nat -F ${tag} 2>/dev/null || true

    # Create a new chain appending at the end.
    # ip46tables -t nat -N ${tag} 2>/dev/null || true

    # Don't forward pkts with creator in this group. Since after forwarding by clash the packets' owner would be the one in group, this helps us to avoid dead loop in packet forwarding.
    # ip46tables -t nat -A ${tag} -m owner --gid-owner ${socksGroupName} -j RETURN 2>/dev/null || true

    # Forward all TCP traffic to the redir port of Clash.
    # ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

    # For all TCP traffic on OUTPUT chain, put them into our newly created chain.
    # ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    preStart = ''
      ${helper}
      ip46tables -t nat -F ${tag} 2>/dev/null || true
      ip46tables -t nat -N ${tag} 2>/dev/null || true
      ip46tables -t nat -A ${tag} -m owner --gid-owner ${socksGroupName} -j RETURN 2>/dev/null || true
      ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

      ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    '';

    postStop = ''
      ${iptables}/bin/iptables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/iptables-restore -c
      ${optionalString config.networking.enableIPv6 ''
        ${iptables}/bin/ip6tables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/ip6tables-restore -c
      ''}
    '';

    # Don't start if the config file doesn't exist.
    unitConfig = { ConditionPathExists = configPath; };
    serviceConfig = {
      Group = socksGroupName;
      Restart = "on-failure";
    };
  };
}
