# An declarative, systemd-managed, and on-demand management builtin Minecraft Server module, adapted from the one in official repo.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.icebox.static.system.minecraft-server;

  # We don't allow eula=false anyways
  eulaFile = builtins.toFile "eula.txt" ''
    # eula.txt managed by NixOS Configuration
    eula=true
  '';

  whitelistFile = pkgs.writeText "whitelist.json" (builtins.toJSON
    (mapAttrsToList (n: v: {
      name = n;
      uuid = v;
    }) cfg.whitelist));

  opsFile = pkgs.writeText "ops.json" (builtins.toJSON cfg.ops);

  cfgToString = v: if builtins.isBool v then boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + concatStringsSep "\n"
    (mapAttrsToList (n: v: "${n}=${cfgToString v}") cfg.serverProperties));

  # To be able to open the firewall, we need to read out port values in the
  # server properties, but fall back to the defaults when those don't exist.
  # These defaults are from https://minecraft.gamepedia.com/Server.properties#Java_Edition_3
  queryPort = if cfg.serverProperties.enable-query or false then
    cfg.serverProperties."query.port" or 25565
  else
    null;

  minecraftUUID = types.strMatching
    "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" // {
      description = "Minecraft UUID";
    };

in {
  options = {
    icebox.static.system.minecraft-server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Server. The server
          data will be loaded from and saved to
          <option>services.minecraft-server.dataDir</option>.
        '';
      };

      eula = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether you agree to
          <link xlink:href="https://account.mojang.com/documents/minecraft_eula">
          Mojangs EULA</link>. This option must be set to
          <literal>true</literal> to run Minecraft server.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/minecraft";
        description = ''
          Directory to store Minecraft database and other state/data files.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for the server.
        '';
      };

      whitelist = mkOption {
        type = types.attrsOf minecraftUUID;
        default = { };
        description = ''
          Whitelisted players, only has an effect when
          <option>services.minecraft-server.declarative</option> is
          <literal>true</literal> and the whitelist is enabled
          via <option>services.minecraft-server.serverProperties</option> by
          setting <literal>white-list</literal> to <literal>true</literal>.
          This is a mapping from Minecraft usernames to UUIDs.
          You can use <link xlink:href="https://mcuuid.net/"/> to get a
          Minecraft UUID for a username.
        '';
        example = literalExample ''
          {
            username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
          };
        '';
      };

      onDemand = mkOption {
        type = with types;
          submodule {
            options = {
              enable = mkOption {
                type = bool;
                default = false;
                description = "Enable Minecraft Server Monitor daemon";
              };
              idleIfTime = mkOption {
                type = int;
                description =
                  "Time in seconds. Idle the server if there is no player on it and this time is exceeded.";
              };
            };
          };
        description =
          "A daemon that monitors the actual Minecraft server. If the server is up and there is no player, then daemon shuts the server down. If the server is down and there is an incoming connection, daemon starts the actual server. Otherwise, daemon does nothing.";
      };

      ops = mkOption {
        type = with types;
          listOf (submodule {
            options = {
              name = mkOption {
                type = str;
                description = "Name of the OP user";
              };
              uuid = mkOption {
                type = minecraftUUID;
                description = ''
                  UUID of the user. Note that the UUIDs for a user in
                  offline mode and online mode are different.
                  You can use <link xlink:href="https://mcuuid.net/"/> to get a
                  Minecraft UUID for a username for online mode.
                  Or you can use <link xlink:href="https://www.fabianwennink.nl/projects/OfflineUUID/"/>
                  for offline mode.
                '';
              };
              level = mkOption {
                type = int;
                description = "Level of the OP permissions for the OP user.";
              };
            };
          });
        description = ''
          Server operators, only has an effect when
          <option>services.minecraft-server.declarative</option> is
          <literal>true</literal>.
        '';
        example = literalExample ''
          [
            {
              uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
              name = "username1";
              level = 4;
            }
            {
              uuid = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
              name = "username2";
              level = 3;
            }
          ];
        '';
      };

      serverIp = mkOption {
        type = types.str;
        description = "IP address bond to the Minecraft server.";
      };

      serverPort = mkOption {
        type = types.port;
        description = "Port that the Minecraft server listens on.";
        default = 25565;
      };

      rconPassword = mkOption {
        type = types.str;
        description = "Password of the server's RCON service.";
      };

      rconPort = mkOption {
        type = types.port;
        description = "Port of the server's RCON service.";
        default = 25575;
      };

      serverProperties = mkOption {
        type = with types; attrsOf (oneOf [ bool int str ]);
        default = { };
        example = literalExample ''
          {
            server-port = 43000;
            difficulty = 3;
            gamemode = 1;
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "hunter2";
          }
        '';
        description = ''
          Minecraft server properties for the server.properties file. Only has
          an effect when <option>services.minecraft-server.declarative</option>
          is set to <literal>true</literal>. See
          <link xlink:href="https://minecraft.gamepedia.com/Server.properties#Java_Edition_3"/>
          for documentation on these values.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.minecraft-server;
        defaultText = "pkgs.minecraft-server";
        example = literalExample "pkgs.minecraft-server_1_12_2";
        description = "Version of minecraft-server to run.";
      };

      jvmOpts = mkOption {
        type = types.separatedString " ";
        default = "-Xmx2048M -Xms2048M";
        # Example options from https://minecraft.gamepedia.com/Tutorials/Server_startup_script
        example = "-Xmx2048M -Xms4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
          + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
          + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
        description = "JVM options for the Minecraft server.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common configuration that applies to both on-demand server management on or off.
    ({
      icebox.static.system.minecraft-server.serverProperties = {
        server-port = mkDefault cfg.serverPort;
        enable-rcon = true;
        "rcon.port" = mkDefault cfg.rconPort;
        "rcon.password" = mkDefault cfg.rconPassword;
      };

      users.users.minecraft = {
        description = "Minecraft server service user";
        home = cfg.dataDir;
        createHome = true;
        uid = config.ids.uids.minecraft;
      };

      systemd.services.minecraft-server = {
        description = "Minecraft Server Service";
        after = [ "network.target" ];

        unitConfig.StopWhenUnneeded = true;
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/minecraft-server ${cfg.jvmOpts}";
          ExecStop =
            "${pkgs.mcrcon}/bin/mcrcon -H 127.0.0.1 -p ${cfg.rconPassword} -P ${
              toString cfg.rconPort
            } stop";
          Restart = "always";
          User = "minecraft";
          WorkingDirectory = cfg.dataDir;
          KillMode = "none";
          PrivateNetwork = true;
          PrivateTmp = true;
        };

        preStart = ''
          ln -sf ${eulaFile} eula.txt
          if [ -e .declarative ]; then
            # Was declarative before, no need to back up anything
            ln -sf ${whitelistFile} whitelist.json
            cp -f ${serverPropertiesFile} server.properties
            cp -f ${opsFile} ops.json
          else
            # Declarative for the first time, backup stateful files
            ln -sb --suffix=.stateful ${whitelistFile} whitelist.json
            cp -b --suffix=.stateful ${serverPropertiesFile} server.properties
            cp -b --suffix=.stateful ${opsFile} ops.json
            # server.properties must have write permissions, because every time
            # the server starts it first parses the file and then regenerates it..
            chmod +w server.properties
            # For the same reason, ops.json has to have write permissions as well.
            chmod +w ops.json
            echo "Autogenerated file that signifies that this server configuration is managed declaratively by NixOS" \
              > .declarative
          fi
        '';
      };

      networking.firewall = mkIf cfg.openFirewall {
        allowedUDPPorts = [ cfg.serverProperties.server-port ];
        allowedTCPPorts =
          [ cfg.serverProperties.server-port cfg.serverProperties."rcon.port" ]
          ++ optional (queryPort != null) queryPort;
      };

      assertions = [{
        assertion = cfg.eula;
        message = "You must agree to Mojangs EULA to run minecraft-server."
          + " Read https://account.mojang.com/documents/minecraft_eula and"
          + " set `services.minecraft-server.eula` to `true` if you agree.";
      }];

    })

    (mkIf (!cfg.onDemand.enable) {
      # If there is no on-demand server management, start minecraft-server on the actual server-ip.
      icebox.static.system.minecraft-server.serverProperties.server-ip =
        mkDefault cfg.serverIp;
    })

    (mkIf (cfg.onDemand.enable) {
      # We want to start the actual server on localhost so our on-demand server management mechanism can work as expected.
      icebox.static.system.minecraft-server.serverProperties.server-ip =
        "127.0.0.1";

      systemd.services = {
        # This service serves as a bi-directional relay between the actual server and systemd socket
        proxy-minecraft-server = {
          # Since we explicitly stops minecraft-server.target (minecraft-server.service as well since state propagates) if there is no one on the server, this proxy would stop as well.
          requires =
            [ "minecraft-server.target" "proxy-minecraft-server.socket" ];
          after = [ "minecraft-server.target" "proxy-minecraft-server.socket" ];

          # Share the same network namespace, so the network traffic could be reacheable.
          unitConfig.JoinsNamespaceOf = "minecraft-server.service";
          serviceConfig = {
            # FIXME: Use --exit-idle-time after the release of systemd v246
            ExecStart =
              "${config.systemd.package}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${
                toString cfg.serverPort
              }";
            PrivateTmp = true;
            PrivateNetwork = true;
          };
        };

        minecraftd = let
          # This script continuously tries to get the number of online players using RCON. If RCON fails to connect or there is at least one player, it would come to another loop, else it exits with 0.
          execScript = pkgs.writeShellScript "minecraftd" ''
            while true; do
              if [[ "$(${pkgs.mcrcon}/bin/mcrcon -H 127.0.0.1 -p ${cfg.rconPassword} -P ${
                toString cfg.rconPort
              } list 2>/dev/null | ${pkgs.gnugrep}/bin/grep "There are" | ${pkgs.gnused}/bin/sed -r -e 's/.*\: //' -e 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/' | ${pkgs.coreutils}/bin/tr -d '\n')" == "0" ]]; then
                echo "No players online currently."
                exit 0
              fi
              echo "There are players online or undetermined."
              ${pkgs.coreutils}/bin/sleep ${toString cfg.onDemand.idleIfTime}
            done
          '';
          # This script stops our target which propagates its state to minecraftd.service and the actual server service
          postStopScript = pkgs.writeShellScript "minecraftd-poststop"
            "${config.systemd.package}/bin/systemctl stop minecraft-server.target";
        in {
          description = "Minecraft Server Monitoring daemon";
          after = [ "network.target" ];
          partOf = [ "minecraft-server.target" ];

          # Share the same network namespace, so the network traffic could be reacheable.
          unitConfig.JoinsNamespaceOf = "minecraft-server.service";
          serviceConfig = {
            ExecStart = execScript;
            ExecStopPost = "+${postStopScript}";
            # Don't restart if it got a clean exit, else our script would run again after it exits if there is no player.
            Restart = "on-failure";
            User = "minecraft";
            # To use JoinsNamespaceOf, we have to set following protection flags.
            PrivateNetwork = true;
            PrivateTmp = true;
          };
        };
        # Group actual server into our target
        minecraft-server.partOf = [ "minecraft-server.target" ];
      };

      systemd.targets.minecraft-server = {
        # Therefore, starting this targets propagates to all services below.
        requires = [ "minecraft-server.service" "minecraftd.service" ];
        # Just be safe. reach the target after all the services are up.
        after = [ "minecraft-server.service" "minecraftd.service" ];
      };

      systemd.sockets.proxy-minecraft-server = {
        # We listen on the real address
        listenStreams = [ "${cfg.serverIp}:${toString cfg.serverPort}" ];
        # Start this socket on boot
        wantedBy = [ "sockets.target" ];
        # Don't start multiple instances of corresponding service.
        socketConfig.Accept = false;
      };
    })
  ]);
}
