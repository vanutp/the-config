{
  self,
  config,
  pkgs,
  ...
}: {
  networking.nat.enable = true;
  networking.firewall.allowedUDPPorts = [51820];
  networking.wg-quick.interfaces = let
    makeWg0 = import "${self}/utils/makeWg0.nix";
  in {
    wg0 = makeWg0 config {
      address = "10.1.0.5";
      isInternal = true;
      autostart = true;
    };
    wg1 = {
      address = ["10.3.0.1/16"];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wg_keys/wg1".path;

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
          # s2
          publicKey = "R50v8ZmGFPPjoHXNfAPEnv7c9B7Hcs7Nq6DYQ9Q/kg8=";
          allowedIPs = ["10.3.0.2/32"];
        }
        {
          # laptop
          publicKey = "0HcEd9CrX9+MgCfx51KvYVL/C6aHGHIzcwGk2k4iX04=";
          allowedIPs = ["10.3.1.2/32"];
        }
        {
          # phone
          publicKey = "fupQFVCXLXt9wY5v0TPoS28FpZi+QsnZp1RdrzU5+Ec=";
          allowedIPs = ["10.3.1.4/32"];
        }
        {
          # filusha
          publicKey = "ymFzfMJN7+pufjwlIE/NFX28FWavQ56LRWHytw/n1kQ=";
          allowedIPs = ["10.3.1.5/32"];
        }
        {
          # elena
          publicKey = "dOK2UXSpa0ds/odkPDwPmYiXH2RvZORu/nmLNDdDghE=";
          allowedIPs = ["10.3.1.6/32"];
        }
        {
          # gravity
          publicKey = "P8XqFnDJOs6zzEVAy4CL5PAYuLfYencxUlDlRg3FGkg=";
          allowedIPs = ["10.3.1.7/32"];
        }
        {
          # lumi
          publicKey = "q+AywhwRwZBdtd8IlEBQIzr4kVtBZa3NyAnEPJ9QPSw=";
          allowedIPs = ["10.3.1.8/32"];
        }
      ];
    };
  };
}
