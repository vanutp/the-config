{...}: {
  virtualisation.composter.apps.pyaterochka.services = {
    bot = {
      image = "registry.vanutp.dev/pyaterochka/bot:latest";
      environment = {
        SERVER_ADDRESS = "https://pyaterochka.vanutp.dev";
      };
      env_file = "bot.env";
      volumes = ["./bot_data:/app/data"];
    };
    server = {
      image = "registry.vanutp.dev/pyaterochka/server:latest";
      traefik.host = "pyaterochka.vanutp.dev";
      env_file = "server.env";
    };
  };
}
