{pkgs, ...}: let
  strongswanNM = pkgs.strongswanNM.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ ["--enable-eap-tls"];
  });
in {
  networking.networkmanager.plugins = [
    (
      pkgs.networkmanager_strongswan.override {
        inherit strongswanNM;
      }
    )
  ];
  services.dbus.packages = [strongswanNM];
  environment.etc = {
    # strongswan expects one certificate per file for some reason
    # i hate this i hate this
    "ssl/certs/DigiCert_Global_Root_CA:83be056904246b1a1756ac95991c74a.crt".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/DigiCert_Global_Root_CA:83be056904246b1a1756ac95991c74a.crt";
    "ssl/certs/ISRG_Root_X1:8210cfb0d240e3594463e0bb63828b00.crt".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/ISRG_Root_X1:8210cfb0d240e3594463e0bb63828b00.crt";
  };
}
