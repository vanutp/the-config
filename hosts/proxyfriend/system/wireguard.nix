{
  config,
  pkgs,
  util,
  ...
}: {
  networking.nat.enable = true;
  networking.firewall.allowedUDPPorts = [51820 45372 45373];
  networking.wg-quick.interfaces = {
    wg0 = util.mkWg0 {
      address = "10.1.0.5";
      isInternal = true;
      autostart = true;
    };
    wg1 = {
      address = ["10.3.0.1/16"];
      listenPort = 45372;
      privateKeyFile = config.sops.secrets."wg_keys/wg1".path;
      type = "amneziawg";
      extraOptions = {
        Jc = 12;
        Jmin = 567;
        Jmax = 696;
        S1 = 82;
        S2 = 44;
        H1 = 913185510;
        H2 = 561456501;
        H3 = 1095959564;
        H4 = 448867668;
      };

      # TODO: do this using networking.nat
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg1 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.3.0.0/16 -o ens3 -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg1 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.3.0.0/16 -o ens3 -j MASQUERADE
      '';

      peers = [
        {
          # monoblock
          publicKey = "eRDI0NIsMGRRAbXsl4xID23fIFSybIzbei4iGXHPNlY=";
          allowedIPs = ["10.3.1.2/32"];
        }
        {
          # gravity
          publicKey = "UsokN3qGp3Us30Grg/VraZsSc6KZN+1+sEJRwxYZD2Y=";
          allowedIPs = ["10.3.1.3/32"];
        }
        {
          # gravity 2
          publicKey = "CK3WxeGPO2Q1xfeWV+2dwoyI2umfcz6beiB5mIcezz4=";
          allowedIPs = ["10.3.1.4/32"];
        }
      ];
    };

    wg2 = {
      address = ["10.4.0.1/16"];
      listenPort = 45373;
      privateKeyFile = config.sops.secrets."wg_keys/wg2".path;

      # TODO: do this using networking.nat
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg2 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.4.0.0/16 -o ens3 -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg2 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.4.0.0/16 -o ens3 -j MASQUERADE
      '';

      peers = [
        {
          # gravity
          publicKey = "zM6LWVYyNNgWc8KJ+Bi6u/Do5zMoAyQq48yFvvvNaA4=";
          allowedIPs = ["10.4.1.1/32"];
        }
      ];
    };
  };
}
