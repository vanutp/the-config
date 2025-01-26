{...}: {
  vanutp.traefik = {
    enable = true;
    requestWildcardCertsFor = ["progtime.net"];
  };
  virtualisation.composter.vhap-update-host = "vhap-update.progtime.net";
}
