{
  common,
  config,
  ...
}: {
  imports = let
    auth = ["foxlab-pt"];
  in [
    (common.blocks.progtime {
      inherit auth;
      domain = "my.progtime.net";
      secretsFile = config.sops.secrets."services/my_progtime_net".path;
      backendCfg = {
        INSTANCE_TITLE = "Прогтайм";
        INSTANCE_SUBTITLE = "";
        WORKERS = "2";
      };
      invokerCfg.ENABLE_INTERACTIVE = "True";
    })
    (common.blocks.progtime {
      inherit auth;
      domain = "demo.progtime.net";
      secretsFile = config.sops.secrets."services/demo_progtime_net".path;
      backendCfg = {
        INSTANCE_TITLE = "Прогтайм";
        INSTANCE_SUBTITLE = "";
        WORKERS = "1";
      };
      invokerCfg.ENABLE_INTERACTIVE = "True";
    })
  ];
}
