{...}: {
  virtualisation.composter.apps.pb_ilkras_ru = {
    backup.enable = true;
    auth = ["foxlab"];
    services.main = {
      image = "registry.vanutp.dev/vanutp/haste-server:latest";
      environment = {
        STORAGE_FILEPATH = "/data";
        STORAGE_TYPE = "file";
      };
      traefik = {
        host = "pb.ilkras.ru";
        port = 7777;
      };
      volumes = ["./data:/data"];
    };
  };
}
