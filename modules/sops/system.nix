{
  hostPath,
  lib,
  util,
  ...
}: let
  convertSecrets' = prefix: contents:
    lib.flatten (
      if prefix == "sops/"
      then null
      else if builtins.isAttrs contents
      then lib.mapAttrsToList (k: v: convertSecrets' "${prefix}${k}/" v) contents
      else {"${lib.removeSuffix "/" prefix}" = {};}
    );
  convertSecrets = contents:
    lib.mergeAttrsList (
      lib.filter (x: x != null) (
        convertSecrets' "" contents
      )
    );
in {
  sops = {
    defaultSopsFile = "${hostPath}/system/secrets.yml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = convertSecrets (util.readYaml "${hostPath}/system/secrets.yml");
  };
}
