{
  common,
  config,
  ...
}: {
  security.sudo.extraRules =
    builtins.concatMap (
      sc:
        map
        (int: {
          users = ["fox"];
          commands = [
            {
              command = "${sc} start wg-quick-${int}";
              options = ["NOPASSWD"];
            }
            {
              command = "${sc} stop wg-quick-${int}";
              options = ["NOPASSWD"];
            }
            {
              command = "${sc} restart wg-quick-${int}";
              options = ["NOPASSWD"];
            }
          ];
        })
        ["int" "wg0" "wg2" "wg2-only"]
    )
    ["/run/current-system/sw/bin/systemctl" "/home/fox/.nix-profile/bin/systemctl"];

  networking.wg-quick.interfaces = {
    int = common.atoms.makeWg0 config {
      address = "10.1.1.2";
      isInternal = true;
      autostart = true;
    };
    wg0 = common.atoms.makeWg0 config {
      address = "10.1.1.2";
      isInternal = false;
      autostart = false;
    };
    wg2 = {
      autostart = false;
      address = ["10.3.1.2/16"];
      privateKeyFile = config.sops.secrets."wg_keys/wg2".path;
      peers = [
        {
          publicKey = "67Br5DrR+rGYPojECxyV2CnTxgAtUzhDdE6WAjaXpAI=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "89.110.74.194:51820";
          persistentKeepalive = 30;
        }
      ];
    };
    wg2-only = {
      autostart = false;
      address = ["10.3.1.2/16"];
      privateKeyFile = config.sops.secrets."wg_keys/wg2".path;
      peers = [
        {
          publicKey = "67Br5DrR+rGYPojECxyV2CnTxgAtUzhDdE6WAjaXpAI=";
          allowedIPs = ["10.3.0.0/16"];
          endpoint = "89.110.74.194:51820";
          persistentKeepalive = 30;
        }
      ];
    };
  };
}
