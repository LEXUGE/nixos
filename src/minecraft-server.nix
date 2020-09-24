{ pkgs, ... }: {
  netkit.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;

    onDemand = {
      enable = true;
      idleIfTime = 60;
      serverPort = 33333;
    };

    ops = [
      {
        # Offline UUID Generated for AshBreaker1: 94f4d16b-0e0b-39e3-9a92-a26bf4f7a0dc
        uuid = "94f4d16b-0e0b-39e3-9a92-a26bf4f7a0dc";
        name = "AshBreaker1";
        level = 4;
      }
      {
        # Official UUID issued by Mojang: 65bec9be-2cb8-46c8-bab5-2a5219759a4a
        uuid = "65bec9be-2cb8-46c8-bab5-2a5219759a4a";
        name = "AshBreaker1";
        level = 4;
      }
    ];

    whitelist = {
      SIMON1314520 =
        "5f18149d-a806-3491-b5fc-75fadee9154f"; # Simon Shu - Offline
      btbtbt = "36866b49-0e29-3b96-b80c-c8eda7cfe3ff"; # Newt Chen - Offline
      AshBreaker1 = "94f4d16b-0e0b-39e3-9a92-a26bf4f7a0dc"; # Offline
      Ju_Mao_Qiu =
        "e50f94f7-9fe0-3b89-85fe-240964188a37"; # Cindy Fang - Offline
      york_Ying = "421a1e44-6280-3e85-97c9-e2029145b1c6"; # York Ying - Offline
      Mac-GM = "e261565d-0856-3d15-b3ae-401014fc10fd"; # Billy Xu - Offline
      # AshBreaker1 = "65bec9be-2cb8-46c8-bab5-2a5219759a4a"; # Online
      mick233 = "d32170e2-5cd8-35b5-9fac-2c71854318ef";
      sam_shen = "c83f7303-19fa-350c-a94f-d5dca5a03c52"; # Sam Shen - Offline
    };

    serverProperties = {
      online-mode = false;
      max-players = 30;
      level-name = "newera2";
      white-list = true;
      #enable-rcon = true;
      difficulty = "normal";
      #"rcon.password" = "nixos";
      network-compression-threshold =
        64; # Compress any packets larger than 64 bytes
      max-world-size = 2000;
      motd =
        "\\u00A76NewEra \\u00A77Vanilla \\u00A7cSurvival\\u00A7r\\n\\u00A7bt.me/NewEraMinecraft";
    };
  };
}
