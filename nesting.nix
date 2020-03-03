# Nesting for realizing easy-to-switch states of transparent proxy on GRUB

{ pkgs, config, lib, ... }:

let
  inherit (pkgs) callPackage gnugrep;
  inherit (lib) concatMapStringsSep;
  mainUser = "ash";

  socksGroupName = "Shadowsocks";
  socksProxyAddr = "127.0.0.1";
  socksProxyPort = 1080;
  redirProxyPort = 1081;
  socksProxyPortStr = toString socksProxyPort;
  redirProxyPortStr = toString redirProxyPort;

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

  transparentProxyConfig = {
    systemd.services.shadowsocks-transparent = {
      description = "Transparent Shadowsocks";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.shadowsocks-libev pkgs.simple-obfs ];
      script =
        "exec ss-redir -c ${configPath} -b ${socksProxyAddr} -l ${redirProxyPortStr}";

      unitConfig = { ConditionPathExists = configPath; };
      serviceConfig = {
        User = mainUser;
        Group = socksGroupName;
        Restart = "on-failure";
      };
    };

    networking.firewall.extraCommands = ''
      ip46tables -t nat -F ${tag} 2>/dev/null || true
      ip46tables -t nat -N ${tag} 2>/dev/null || true
      ${doNotRedirect}

      ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}
      ip46tables -t nat -A OUTPUT -p tcp -j ${tag} 2>/dev/null || true
    '';
  };
in {
  users.groups.${socksGroupName} = { };
  systemd.services.shadowsocks = {
    description = "Shadowsocks";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.shadowsocks-libev pkgs.simple-obfs ];
    script =
      "exec ss-local -c ${configPath} -b ${socksProxyAddr} -l ${socksProxyPortStr}";

    unitConfig = { ConditionPathExists = configPath; };
    serviceConfig = {
      User = mainUser;
      Group = socksGroupName;
      Restart = "on-failure";
    };
  };

  networking.firewall.extraStopCommands = ''
    iptables-save -c|${gnugrep}/bin/grep -v ${tag}|iptables-restore -c
  '';

  nesting.clone = [
    ({
      boot.loader.grub.configurationName = "Global Redir";
    } // transparentProxyConfig)
  ];
}
