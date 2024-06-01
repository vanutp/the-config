config: {
  registry = "registry.vanutp.dev";
  username = "vanutp";
  passwordFile = config.sops.secrets."vanutp-registry-password".path;
}
