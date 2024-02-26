{config, ...}: {
  networking.wg-quick.interfaces = let
    makeWg0 = allowedIPs: autostart: {
      autostart = autostart;
      address = ["10.1.1.2/16"];
      privateKeyFile = config.sops.secrets."wg_keys/wg0".path;
      peers = [
        {
          publicKey = "7xWhdFY5hRzcqCJCPjb4Ln1uwFqLIi0ctQ7R4Gq9owY=";
          allowedIPs = [allowedIPs];
          endpoint = "82.146.39.189:51820";
          persistentKeepalive = 30;
        }
      ];
    };
  in {
    int = makeWg0 "10.1.0.0/16" true;
    wg0 = makeWg0 "0.0.0.0/0" false;
    wg2 = {
      autostart = false;
      address = ["10.3.1.2/16"];
      privateKeyFile = config.sops.secrets."wg_keys/wg2".path;
      peers = [
        {
          publicKey = "67Br5DrR+rGYPojECxyV2CnTxgAtUzhDdE6WAjaXpAI=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "217.151.231.127:51820";
          persistentKeepalive = 30;
        }
      ];
    };
  };
}
