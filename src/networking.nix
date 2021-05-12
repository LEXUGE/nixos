{ pkgs, ... }: {
  # Lower down the timeout values to reduce stress on conntrack.
  # https://security.stackexchange.com/questions/43205/nf-conntrack-table-full-dropping-packet
  boot.kernel.sysctl = {
    "net.netfilter.nf_conntrack_generic_timeout" = 60;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 54000;
  };

  services.v2ray = {
    enable = true;
    config = {
      log.loglevel = "info";
      inbounds = [{
        port = 1080;
        protocol = "socks";
        sniffing = {
          enabled = true;
          destOverride = [ "http" "tls" ];
        };
        settings = { auth = "noauth"; };
      }];
      outbounds = [{
        protocol = "vmess";
        settings = {
          vnext = [{
            address = "175.24.191.112";
            port = 53;
            users = [{
              id = "1e20eca6-8bd8-512d-596f-6067be9f3a17";
              alterId = 64;
            }];
          }];
        };
        streamSettings = {
          network = "mkcp";
          kcpSettings = {
            uplinkCapacity = 100;
            downlinkCapacity = 100;
            congestion = true;
            header = { type = "wechat-video"; };
          };
        };
      }];
    };
  };

  netkit = {
    clash = {
      enable = true;
      redirPort = 7892; # This must be the same with the one in your clash.yaml
      afterUnits = [ "dcompass.service" ];
    };

    snapdrop = {
      enable = true;
      package = pkgs.nixos-cn.snapdrop;
    };

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
