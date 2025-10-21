{pkgs, ...}: {
  systemd.services.copy-certs = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      WorkingDirectory = "/srv/vhap/traefik";
    };
    path = [
      pkgs.inotify-tools
      pkgs.jq
      pkgs.openssh
    ];
    script = ''
      set -e
      inotifywait -q -m -e close_write data/tls/acme.json |
          while read -r filename event; do
              data=$(cat data/tls/acme.json | jq '.default.Certificates[] | select(.domain.main == "vanutp.dev")')
              certificate=$(echo $data | jq -r '.certificate')
              key=$(echo $data | jq -r '.key')
              command="sudo bash -c \"echo $certificate | base64 -d > /etc/nginx/certs/vanutp.dev/fullchain3.pem && echo $key | base64 -d > /etc/nginx/certs/vanutp.dev/privkey3.pem && systemctl reload nginx\""
              ssh fox@s4 -oStrictHostKeyChecking=no -i /home/fox/.ssh/id_rsa "$command"
              echo "Updated certificates"
          done
    '';
  };
}
