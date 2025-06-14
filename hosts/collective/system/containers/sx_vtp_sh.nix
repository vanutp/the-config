{
  config,
  pkgs,
  ...
}: let
  uwsgi-ini = pkgs.writeText "searxng-uwsgi.ini" ''
    [uwsgi]
    http-socket = $(BIND_ADDRESS)
    uid = searxng
    gid = searxng
    workers = 2
    threads = 4
    chmod-socket = 666
    single-interpreter = true
    master = true
    lazy-apps = true
    enable-threads = 4
    module = searx.webapp
    pythonpath = /usr/local/searxng/
    chdir = /usr/local/searxng/searx/
    auto-procname = true
    disable-logging = true
    log-5xx = true
    buffer-size = 8192
    add-header = Connection: close
    die-on-term
    static-map = /static=/usr/local/searxng/searx/static
    static-gzip-all = True
    offload-threads = 4
  '';
in {
  sops.secrets."services/sx_vtp_sh/key" = {};
  sops.templates."searxng.yml" = {
    uid = 977;
    gid = 977;
    content = builtins.toJSON {
      use_default_settings = true;
      server = {
        base_url = "https://sx.vtp.sh/";
        secret_key = config.sops.placeholder."services/sx_vtp_sh/key";
        method = "GET";
      };
      ui = {
        static_use_hash = true;
        query_in_title = true;
      };
      search = {
        favicon_resolver = "google";
        autocomplete = "google";
        formats = [
          "html"
          "json"
        ];
      };
      hostnames = {
        replace = {
          "^reddit\.com$" = "redlib.catsarch.com";
          "^twitter\.com$" = "nitter.privacyredirect.com";
          "^x\.com$" = "nitter.privacyredirect.com";
        };
        high_priority = [
          "^modrinth\.com$"
        ];
      };
      general.instance_name = "Foxy Search";
      redis.url = "redis://redis:6379/0";
    };
  };

  virtualisation.composter.apps.sx_vtp_sh.services = {
    main = {
      image = "searxng/searxng";
      traefik.host = "sx.vtp.sh";
      volumes = [
        "${config.sops.templates."searxng.yml".path}:/etc/searxng/settings.yml:ro"
        "${uwsgi-ini}:/etc/searxng/uwsgi.ini:ro"
      ];
      labels = {
        "traefik.http.routers.sx__vtp__sh.middlewares" = "authelia@docker";
      };
    };
    redis = {
      image = "redis:alpine";
      volumes = ["./redis:/data"];
    };
  };
}
