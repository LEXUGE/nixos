{
  netkit = {
    clash = {
      enable = true;
      redirPort = 7892; # This must be the same with the one in your clash.yaml
      afterUnits = [ "smartdns.service" ];
    };

    smartdns = {
      enable = true;
      china-list = true;
      settings = {
        bind = "[::]:53";
        cache-size = 4096;
        server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
        server-https = "https://cloudflare-dns.com/dns-query";
        server = [
          "114.114.114.114 -group china"
          "10.20.0.233 -group china"
          "223.5.5.5 -group china"
        ]; # Server for China-list
        prefetch-domain = true;
        speed-check-mode = "ping,tcp:80";
      };
    };

    snapdrop.enable = true;

    wifi-relay = {
      enable = true;
      interface = "wlp0s20f3";
      ssid = "AP-Freedom";
      passphrase = "88888888";
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
