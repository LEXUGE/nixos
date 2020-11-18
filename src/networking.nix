{
  # Lower down the timeout values to reduce stress on conntrack.
  # https://security.stackexchange.com/questions/43205/nf-conntrack-table-full-dropping-packet
  boot.kernel.sysctl = {
    "net.netfilter.nf_conntrack_generic_timeout" = 60;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 54000;
  };

  netkit = {
    # Testing purpose only
    smartdns = {
      enable = true;
      china-list = true;
      settings = {
        bind = "[::]:3053";
        log-level = "debug";
        cache-size = 4096;
        server-https =
          [ "https://1.1.1.1/dns-query" "https://9.9.9.9/dns-query" ];
        server = [
          "114.114.114.114 -group china -exclude-default-group"
          "223.5.5.5 -group china -exclude-default-group"
        ]; # Server for China-list
        prefetch-domain = true;
      };
    };

    clash = {
      enable = true;
      redirPort = 7892; # This must be the same with the one in your clash.yaml
      afterUnits = [ "dcompass.service" ];
    };

    snapdrop.enable = true;

    wifi-relay = {
      enable = true;
      interface = "wlp0s20f3";
      ssid = "AP-Freedom";
      passphrase = "88888888";
      # dns = "114.114.114.114, 8.8.8.8, 223.5.5.5";
    };

    frpc = {
      enable = true;
      frpcConfig = {
        common = {
          server_addr = "175.24.191.112";
          server_port = 7000;
          tls_enable = true;
          authentication_method = "token";
          token = "2007f015-fbae-438d-a348-73310678cd11";
        };

        minecraft-server = {
          type = "tcp";
          local_ip = "127.0.0.1";
          local_port = 33333;
          remote_port = 33333;
          use_compression = true;
        };
      };
    };
  };
}
