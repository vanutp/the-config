{pkgs, ...}: let
  config = pkgs.writeText "nginx.conf" ''
    server {
      listen  80 default_server;
      listen  [::]:80 default_server;
      server_name _;
      location / {
        root /app;
        index index.html;
        try_files $uri $uri/ /index.html;
      }
    }
  '';
in {
  virtualisation.composter.apps.collective_vanutp_dev.services.main = {
    image = "nginx:alpine";
    traefik.host = "collective.vanutp.dev";
    volumes = [
      "./content:/app:ro"
      "${config}:/etc/nginx/conf.d/default.conf:ro"
    ];
  };
}
