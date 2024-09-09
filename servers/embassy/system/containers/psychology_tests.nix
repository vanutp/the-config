{...}: {
  virtualisation.composter.apps.psychology_tests.services.main = {
    image = "registry.vanutp.dev/vanutp/psychology_tests";
    env_file = ".env";
    volumes = ["./data:/app/data"];
  };
}
