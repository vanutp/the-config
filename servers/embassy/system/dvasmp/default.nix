{
  pkgs,
  common,
  ...
}: let
  mcDir = "/srv/dvasmp";
in {
  users = {
    users.dvasmp = {
      isNormalUser = true;
      group = "dvasmp";
      homeMode = "750";
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        common.constants.pubkeys.main
        common.constants.pubkeys.embassy
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYmPAe2ZEE19QYiq4cdL/TRLqluVRX5heOMwnzCO9eu fox@dull-vessel"
      ];
    };
    groups.dvasmp.members = ["nginx"];
  };
  system.activationScripts.create-dvasmp-dir = {
    deps = ["users"];
    text = ''
      mkdir -p ${mcDir}/launcher
      mkdir -p ${mcDir}/data
      chown -R dvasmp:dvasmp ${mcDir}
    '';
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    virtualHosts."mc.vanutp.dev" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8020;
        }
      ];
      locations."/" = {
        root = mcDir;
        index = "index.html";
      };
      locations."= /" = {
        root = ./.;
        tryFiles = "/index.html =404";
      };
    };
  };
  vanutp.traefik.proxies = [
    {
      host = "mc.vanutp.dev";
      target = "http://127.0.0.1:8020";
    }
  ];
}
