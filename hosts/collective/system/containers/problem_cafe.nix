{config, ...}: {
  virtualisation.composter.apps.problem_cafe = {
    auth = ["ghcr"];
    services.main = {
      image = "ghcr.io/vobolgus/problemcafe";
      environment = {
        NODE_ENV = "production";
        PORT = "3001";
        VITE_API_URL = "http://localhost:3001";
        LLM_PROVIDER = "GOOGLE";
        LLM_MODEL = "gemini-2.5-flash";
        LLM_QUERY_MODEL = "gemini-2.0-flash";
        LLM_TAG_MODEL = "gemini-2.5-flash";
        LLM_SOLUTION_MODEL = "gemini-3-pro-preview";
        LLM_SOLUTION_THINKING = "medium";
        LLM_SOLUTION_MAX_TOKENS = "16000";
        LLM_HTTP_TIMEOUT_MS = "180000";
      };
      env_file = config.sops.secrets."problem_cafe".path;
      traefik = {
        host = "problem.cafe";
        certresolver = "http";
        update-dns = false;
      };
      volumes = [
        "./front/data:/app/front/data"
        "./front/uploads:/app/front/uploads"
      ];
    };
  };
  services.vhap-compose-update.entries = [
    {
      key = config.sops.placeholder."vhap-compose-update/problem_cafe";
      services = ["problem_cafe"];
    }
  ];
}
