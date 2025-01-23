{...}: {
  virtualisation.composter.apps.pihole.services.pihole = {
    image = "pihole/pihole:latest";
    environment = {
      TZ = "Europe/Moscow";
      VIRTUAL_HOST = "pi.fox";
    };
    labels = {
      "traefik.http.middlewares.pi__fox.ipwhitelist.sourcerange" = "10.1.0.0/16";
    };
    ports = [
      "10.1.0.1:53:53/tcp"
      "10.1.0.1:53:53/udp"
    ];
    traefik = {
      host = "pi.fox";
      port = 80;
    };
    volumes = [
      "./etc/pihole:/etc/pihole"
      "./etc/dnsmasq.d:/etc/dnsmasq.d"
    ];
  };
}
