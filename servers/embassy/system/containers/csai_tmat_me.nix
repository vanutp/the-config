{...}: {
  virtualisation.composter.apps.csai_tmat_me = {
    auth = ["ghcr"];
    services.main = {
      image = "ghcr.io/tm-a-t/notes:latest";
      traefik = {
        host = "csai.tmat.me";
        port = 80;
      };
      entrypoint = ["uvicorn" "src:app" "--host" "0.0.0.0" "--port" "80"];
      env_file = "secrets.env";
    };
  };
}
