{config, ...}: {
  virtualisation.composter.apps.vosh_results_bot.services.main = {
    image = "registry.vanutp.dev/ilyakrasnovv/lksh_results_bot";
    env_file = config.sops.secrets."services/vosh_results_bot".path;
    environment = {
      PING_URLS = "https://olympiads.ru/moscow/2024-25/vsosh/region_results.shtml";
      NOTIFY_MESSAGE = "Кажется, появились [результаты]({url})!";
      NOTIFY_CHAT = "-1001770146024";
      CONTINUE_WATCHING = "1";
      SEND_PING = "0";
    };
  };
}
