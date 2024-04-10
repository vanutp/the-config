{
  config,
  lib,
  ...
}: {
  options = with lib; {
    vanutp.makeWg0 = mkOption {
      type = types.functionTo types.attrs;
      default = {
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
      };
    };
    vanutp.pubkeys = {
      main = mkOption {
        type = types.str;
        default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVu8etcldhq3qqOfSOCv10RHaIm6gJe+STWnuT/L461c7ftpfTU3pQsl2N6Tl2oeVKQaDsAgxnGZfqmzbDcZ+gFKRUPZ8FvYT/6sk+RuqgowBEVmtUrr6MOC0ydoMz4aqG0XBkICHvpm652YmgGqp0QN9Rd4QU7yvjKGIwwf5mfYd06HUD8J3zuJqRZFVcA0bfEU/oOJh3MV6Eha412XI3Zx866aYgOntbl0Y2sRUZoSbUhezyVw1rJcJEIQdTcL5HjhCoMcvm/6PaMLdwfsxCqnTt9qTD4V/22nIBooypN1HNnmk2AIDZLzOw2A30rhdfC3bOGYmB7LG13zCe1Av7";
      };
      s1 = mkOption {
        type = types.str;
        default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6z3SqhBodYd1LPflDrskTrD1SyUApyzxJm3rBqo7/aVu58Dp/bpQA5+JP0Twe09HiiRRJIZxv8GbMGoNTRn17pF7a/yvxKgqNC79ZdZ/7YXbfO2eLYme21gIFeLKGZkGvSROtbhL4qdHmScRbD8E1noCuJd8h+2MWqlOTBH3H1laKTxLKUnn7/OyH7Zi1ZR77jtAeXTD8VJR/uwFVN7LwsaGjrCz66iozeehmYNPrh8vEAJ27HlmchZTyBeTCC2wG724ZObm3QdCmX4cIKdsABuaisrGUX4BRdQcA76kARnEyA2Odn1UwPNUDoFtrM63IakybVBtLxGq19AAC5MP6qyH2PtoIPfwwRiRwp7zqBB31WzDX7CjVy4Co+ZDljZIQyAY13gTyZudq8VOXjODEN/KslMQawb6PLYlw0kjYkkHXNl10ZN/Xn3AsfWG/IxeqmRGJxsPZ/b0DkF15UCREOKoLvLIoaF+MZvuxS0WO1tXNQyA14CqZHO2j/AXiz9E= fox@s1.vanutp.dev";
      };
    };
  };
}
