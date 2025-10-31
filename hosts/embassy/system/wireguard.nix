{config, ...}: {
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall.allowedUDPPorts = [51820];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.1.0.1/24"];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wg_keys/wg0".path;
      peers = [
        {
          # s2
          publicKey = "E0R5NivtOXl+iGnFJfUe5CJ7qZaJ9nHrN7tx3t0hbnc=";
          allowedIPs = ["10.1.0.2/32"];
          persistentKeepalive = 5;
        }
        {
          # s4
          publicKey = "D3u/7B8HS3axwiDBIXMnmV59Rv8VTlqCvYWZCDtwV2A=";
          allowedIPs = ["10.1.0.4/32"];
          persistentKeepalive = 30;
        }
        {
          # proxyfriend
          publicKey = "Skxz3qyLM2FUylNq8LTg4DZ3xS500AwT8CrE6sgj8H4=";
          allowedIPs = ["10.1.0.5/32"];
          persistentKeepalive = 30;
        }
        {
          # collective
          publicKey = "Zr5XdftmcPsaDbKrdgRC8YlmtiD7JoE1Btgx046Cbgk=";
          allowedIPs = ["10.1.0.6/32"];
          persistentKeepalive = 30;
        }
        {
          # p1
          publicKey = "rfPqapxJDPbDu/HtPG6i3QvGaFs9gT6vUJQvtbU3XwA=";
          allowedIPs = ["10.1.3.1/32"];
        }
        {
          # a1
          publicKey = "YAYh02O+pL3k4ulL511boux2OFcwjq315eW92K5ZbGw=";
          allowedIPs = ["10.1.4.1/32"];
        }
        {
          # mikrotik-germany
          publicKey = "h6JrjiaD6veZ9Y3rujOP4KWIEW7t/d6QeOzE37DbU0c=";
          allowedIPs = ["10.1.0.7/32"];
        }
        {
          # Ноут
          publicKey = "rw6PGOmChQvnNbimu5G8Te9H4MTwZfMFQNSeosFlMjc=";
          allowedIPs = ["10.1.1.2/32"];
        }
        {
          # Томат
          publicKey = "LPBXc3O2wCNFr+Bld5giiBe2V4LyezjlgcaeXtVjXnE=";
          allowedIPs = ["10.1.1.3/32"];
        }
        {
          # Телефон
          publicKey = "sjGxGtjCCQtzBSSbVbFCX8yUIZDPqw8wAVqB3u3Oyn0=";
          allowedIPs = ["10.1.1.4/32"];
        }
        {
          # Моноблок у бабушки
          publicKey = "SWVZznkudVHNXpVjMxST/gUo3xKp4l53K2N1YiLHvlo=";
          allowedIPs = ["10.1.1.7/32"];
        }
        {
          # Моноблок дома
          publicKey = "6FBqhktFir6ry0u7vrrZ8VR5Q7ESEjDVMjtBxZsclxE=";
          allowedIPs = ["10.1.1.11/32"];
        }
        {
          # Глеб
          publicKey = "+7rlGLOZUjDFUKj3U+kHfcgo+/66blB9Capezx8TjmU=";
          allowedIPs = ["10.1.1.14/32"];
        }
        {
          # Миша
          publicKey = "bihHk5wNMupCCfTWkLZpfEqXHlP6jDlCNjVMDm+qrQo=";
          allowedIPs = ["10.1.1.16/32"];
        }
        {
          # liferooter
          publicKey = "zN0Yo2ISOoSnvoCik7KYfJOjqKyjRhBQuBoi5UfUgSg=";
          allowedIPs = ["10.1.1.18/32"];
        }
        {
          # liferooter 2
          publicKey = "fa0HSgODOoUZtFDbVQZnnZs2Z4UaEijbZasTBGY+ET4=";
          allowedIPs = ["10.1.1.19/32"];
        }
        {
          # thedise
          publicKey = "sgMe1YLD6xTBk8sfoy9AhvuM5iL+fM5qVbgZj9DjKGo=";
          allowedIPs = ["10.1.1.20/32"];
        }
        {
          # Мама ноут
          publicKey = "w6628N7jnYqiHqNShwWhxArRu3X9omrvsLQQoQRu93Q=";
          allowedIPs = ["10.1.1.21/32"];
        }
        {
          # weethet
          publicKey = "Nbov3GZwbh7BIAJw3zB/Vpq5gSnOPiY6ZRRxCFt1ozw=";
          allowedIPs = ["10.1.1.22/32"];
        }
        {
          # lumi
          publicKey = "K8JnO+aVf5Z0hMBrLpz2qXZcpfskgGaeCeX1nMnhNG8=";
          allowedIPs = ["10.1.1.23/32"];
        }
        # Aclass
        {
          publicKey = "AR54/1HJi5PWvjqCzTeKoE9si9/wRYzMsQRnDBMG9DU=";
          allowedIPs = ["10.1.2.3/32"];
        }
        {
          publicKey = "b2cG8YJmvaUfiLskJXZATRB4JqvnDFxIfhKjZtRFFys=";
          allowedIPs = ["10.1.2.4/32"];
        }
        {
          publicKey = "XKIVSBfmFZ4thQ3WQnWPNeBsy7WKReyDoxGo7LyOmCk=";
          allowedIPs = ["10.1.2.5/32"];
        }
        {
          publicKey = "V0ERr422yITIvj1P1WVK1cs4u46/tQyfDJl8qoWQN0Y=";
          allowedIPs = ["10.1.2.6/32"];
        }
        {
          publicKey = "9izYoISWAMpqXcaXnw3yJoD445DFOo/pJwzWnNqZM08=";
          allowedIPs = ["10.1.2.7/32"];
        }
        {
          publicKey = "srm+EzH1vAhAmpeWTWQHIlmySGWY3DWWHikwkVPWDCk=";
          allowedIPs = ["10.1.2.8/32"];
        }
        {
          publicKey = "NZHICJmvVyu4QBz8c+fBOVJqjTAyJQs1QnXZCy8XFg0=";
          allowedIPs = ["10.1.2.9/32"];
        }
        {
          publicKey = "Z5AqzLD9aHXGEukPVN6CToRQkkx6TrjNVPW4fz7SmAc=";
          allowedIPs = ["10.1.2.10/32"];
        }
        {
          publicKey = "LFZtt5EOoBKIwW6iR2YCNcwhaghrbxwoKO5/syDmwiY=";
          allowedIPs = ["10.1.2.11/32"];
        }
        {
          publicKey = "BxNLRK4p3Kep+TdbOnFvNy6m6PyIuLXK+Ta6jTOGMAI=";
          allowedIPs = ["10.1.2.12/32"];
        }
        {
          publicKey = "cW822i6LcCduHdIxrgaLhU4hoJZjOFYdH/KLpoA4fUI=";
          allowedIPs = ["10.1.2.13/32"];
        }
      ];
    };
  };
}
