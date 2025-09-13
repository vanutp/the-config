{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    vanutp.maskman = let
      inherit (lib) mkOption;
      inherit (lib.types) bool str nullOr listOf submodule;
    in {
      enable = mkOption {
        type = bool;
        default = false;
      };
      cloudflare-key-file = mkOption {
        type = str;
        readOnly = true;
      };
      host-ip = mkOption {
        type = str;
        readOnly = true;
      };
      entries = mkOption {
        type = listOf (submodule {
          options = {
            name = mkOption {
              type = str;
            };
            proxied = mkOption {
              type = bool;
              default = true;
            };
            target-interface = mkOption {
              type = nullOr str;
              default = null;
            };
          };
        });
        default = [];
      };
    };
  };
  config = let
    mkJson = (pkgs.formats.json {}).generate;
    cfg = config.vanutp.maskman;
    configFile = mkJson "maskman.json" cfg;
    maskman =
      pkgs.writers.writePython3Bin "maskman" {
        flakeIgnore = ["E501"];
        libraries = [pkgs.python3Packages.httpx];
      }
      ./maskman.py;
  in
    lib.mkIf config.vanutp.maskman.enable {
      vanutp.maskman = {
        host-ip =
          builtins.elemAt
          (lib.strings.splitString "/" config.setup.network.ipv4.address)
          0;
        cloudflare-key-file = config.sops.secrets."vhap-cf-token".path;
      };
      systemd.services.maskman = {
        script = ''
          ${lib.getExe maskman} ${configFile}
        '';
        wantedBy = ["multi-user.target"];
        requires = ["network-online.target"];
        after = ["network-online.target"];
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
}
