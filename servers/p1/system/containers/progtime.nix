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
        LOGIN_TEXT = "<h5 style=\"margin-bottom: 2rem\">Демо инстанс Progtime</h5><p>Логин: admin0<br/>Пароль: admin0</p>";
      };
      invokerCfg.ENABLE_INTERACTIVE = "True";
    })
  ];
}
