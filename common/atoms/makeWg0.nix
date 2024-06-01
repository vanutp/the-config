config: {
  address,
  isInternal,
  autostart,
}: {
  autostart = autostart;
  address = [(address + "/16")];
  privateKeyFile = config.sops.secrets."wg_keys/wg0".path;
  peers = [
    {
      publicKey = "7xWhdFY5hRzcqCJCPjb4Ln1uwFqLIi0ctQ7R4Gq9owY=";
      allowedIPs =
        if isInternal
        then ["10.1.0.0/16"]
        else ["0.0.0.0/0"];
      endpoint = "82.146.39.189:51820";
      persistentKeepalive = 30;
    }
  ];
}
