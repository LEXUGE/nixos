{ pkgs, config, lib, ... }:

let
  inherit (pkgs) gnugrep shadowsocks-libev iptables utillinux;
  inherit (lib) concatMapStringsSep optionalString mkIf;
  cfg = config.meta.system;

  mainUser = cfg.proxy.user;
  socksGroupName = "Shadowsocks";
  socksProxyAddr = cfg.proxy.address;
  socksProxyPortStr = toString cfg.proxy.localPort;
  redirProxyPortStr = toString cfg.proxy.redirPort;

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

  ss = shadowsocks-libev;
  configPath = toString "/etc/nixos/secrets/shadowsocks.json";
  tag = "SS_SPEC_ASH";
  doNotRedirect = concatMapStringsSep "\n"
    (f: "ip46tables -t nat -A ${tag} ${f} -j RETURN 2>/dev/null || true") [
      "-d 0.0.0.0/8"
      "-d 10.0.0.0/8"
      "-d 127.0.0.0/8"
      "-d 172.16.0.0/12"
      "-d 192.168.0.0/16"
      "-d 1.1.1.3"
      "-m owner --gid-owner ${socksGroupName}"
    ];
in mkIf (cfg.proxy != null) {

  users.groups.${socksGroupName} = { };
  systemd.services.shadowsocks = {
    description = "Shadowsocks";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.simple-obfs ];

    serviceConfig = {
      User = mainUser;
      Group = socksGroupName;
      Restart = "on-failure";
    };
    script =
      "${ss}/bin/ss-local -c ${configPath} -b ${socksProxyAddr} -l ${socksProxyPortStr}";
  };

  systemd.services.shadowsocks-transparent = {
    description = "Transparent Shadowsocks";
    after = [ "network.target" ];
    path = [ pkgs.simple-obfs ];
    script = "${utillinux}/bin/runuser -u ${mainUser} -g ${socksGroupName} -- "
      + "${ss}/bin/ss-redir -c ${configPath} -b ${socksProxyAddr} -l ${redirProxyPortStr}";

    preStart = ''
      ${helper}
      ip46tables -t nat -F ${tag} 2>/dev/null || true
      ip46tables -t nat -N ${tag} 2>/dev/null || true
      ${doNotRedirect}

      ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}
      ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    '';

    postStop = ''
      ${iptables}/bin/iptables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/iptables-restore -c
      ${optionalString config.networking.enableIPv6 ''
        ${iptables}/bin/ip6tables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/ip6tables-restore -c
      ''}
    '';

    unitConfig = { ConditionPathExists = configPath; };
    serviceConfig = {
      Group = socksGroupName;
      Restart = "on-failure";
    };
  };
}
