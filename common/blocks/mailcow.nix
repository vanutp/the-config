{
  hostname,
  lite,
}: {
  common,
  config,
  pkgs,
  lib,
  ...
}: let
  rootDir = "${common.constants.servicesDataRoot}/mailcow";
  dataDir = "${common.constants.servicesDataRoot}/mailcow-data";
in {
  # mailcow 2024-04
  networking.firewall.allowedTCPPorts = [25 465 587 143 993 110 995 4190];
  virtualisation.composter.services.mailcow = let
    IPV4_NETWORK = "172.22.1";
    IPV6_NETWORK = "fd4d:6169:6c63:6f77::/64";
    TZ = "Europe/Moscow";
    unboundAddr = "${IPV4_NETWORK}.254";
    REDIS_SLAVEOF_IP = "";
    REDIS_SLAVEOF_PORT = "";
    DBNAME = "mailcow";
    DBUSER = "mailcow";
    SMTP_PORT = "25";
    SMTPS_PORT = "465";
    SUBMISSION_PORT = "587";
    IMAP_PORT = "143";
    IMAPS_PORT = "993";
    POP_PORT = "110";
    POPS_PORT = "995";
    SIEVE_PORT = "4190";
    MAILDIR_SUB = "Maildir";
    MASTER = "y";
  in {
    network = {
      ipv4.subnet = "${IPV4_NETWORK}.0/24";
      ipv6.enable = true;
      ipv6.subnet = IPV6_NETWORK;
    };
    containers = {
      unbound-mailcow = {
        image = "mailcow/unbound:1.21";
        environment = {
          inherit TZ;
          SKIP_UNBOUND_HEALTHCHECK = "n";
        };
        extraOptions = [
          "--ip=${unboundAddr}"
          "--tty"
          "--network-alias=unbound"
        ];
        volumes = [
          "${rootDir}/data/hooks/unbound:/hooks"
          "${rootDir}/data/conf/unbound/unbound.conf:/etc/unbound/unbound.conf:ro"
        ];
      };

      mysql-mailcow = {
        image = "mariadb:10.5";
        dependsOn = ["unbound-mailcow" "netfilter-mailcow"];
        # TODO: stop_grace_period: 45s
        volumes = [
          "${dataDir}/mysql:/var/lib/mysql/"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
          "${rootDir}/data/conf/mysql/:/etc/mysql/conf.d/:ro"
        ];
        environment = {
          inherit TZ;
          MYSQL_DATABASE = DBNAME;
          MYSQL_USER = DBUSER;
          MYSQL_INITDB_SKIP_TZINFO = "1";
        };
        extraOptions = [
          # added by me
          "--ip=${IPV4_NETWORK}.200"
          "--dns=${unboundAddr}"
          "--tty"
          "--network-alias=mysql"
        ];
        environmentFiles = [
          config.sops.secrets."services/mailcow/mysql".path
        ];
      };

      redis-mailcow = {
        image = "redis:7-alpine";
        dependsOn = ["netfilter-mailcow"];
        volumes = [
          "${dataDir}/redis:/data/"
        ];
        environment = {inherit TZ;};
        extraOptions = [
          "--sysctl=net.core.somaxconn=4096"
          "--ip=${IPV4_NETWORK}.249"
          "--network-alias=redis"
        ];
      };

      rspamd-mailcow = {
        image = "mailcow/rspamd:1.95";
        dependsOn = ["dovecot-mailcow"];
        # TODO: stop_grace_period: 30s
        environment = {
          inherit TZ IPV4_NETWORK IPV6_NETWORK REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT;
        };
        volumes = [
          "${rootDir}/data/hooks/rspamd:/hooks"
          "${rootDir}/data/conf/rspamd/custom/:/etc/rspamd/custom"
          "${rootDir}/data/conf/rspamd/override.d/:/etc/rspamd/override.d"
          "${rootDir}/data/conf/rspamd/local.d/:/etc/rspamd/local.d"
          "${rootDir}/data/conf/rspamd/plugins.d/:/etc/rspamd/plugins.d"
          "${rootDir}/data/conf/rspamd/lua/:/etc/rspamd/lua/:ro"
          "${rootDir}/data/conf/rspamd/rspamd.conf.local:/etc/rspamd/rspamd.conf.local"
          "${rootDir}/data/conf/rspamd/rspamd.conf.override:/etc/rspamd/rspamd.conf.override"
          "${dataDir}/rspamd:/var/lib/rspamd"
        ];
        extraOptions = [
          # added by me
          "--ip=${IPV4_NETWORK}.201"
          "--dns=${unboundAddr}"
          "--hostname=rspamd"
          "--network-alias=rspamd"
        ];
      };

      php-fpm-mailcow = {
        image = "mailcow/phpfpm:1.87";
        cmd = ["php-fpm" "-d" "date.timezone=${TZ}" "-d" "expose_php=0"];
        dependsOn = ["redis-mailcow"];
        volumes = [
          "${rootDir}/data/hooks/phpfpm:/hooks"
          "${rootDir}/data/web:/web"
          "${rootDir}/data/conf/rspamd/dynmaps:/dynmaps:ro"
          "${rootDir}/data/conf/rspamd/custom/:/rspamd_custom_maps"
          "${dataDir}/rspamd:/var/lib/rspamd"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
          "${rootDir}/data/conf/sogo/:/etc/sogo/"
          "${rootDir}/data/conf/rspamd/meta_exporter:/meta_exporter:ro"
          "${rootDir}/data/conf/phpfpm/sogo-sso/:/etc/sogo-sso/"
          "${rootDir}/data/conf/phpfpm/php-fpm.d/pools.conf:/usr/local/etc/php-fpm.d/z-pools.conf"
          "${rootDir}/data/conf/phpfpm/php-conf.d/opcache-recommended.ini:/usr/local/etc/php/conf.d/opcache-recommended.ini"
          "${rootDir}/data/conf/phpfpm/php-conf.d/upload.ini:/usr/local/etc/php/conf.d/upload.ini"
          "${rootDir}/data/conf/phpfpm/php-conf.d/other.ini:/usr/local/etc/php/conf.d/zzz-other.ini"
          "${rootDir}/data/conf/dovecot/global_sieve_before:/global_sieve/before"
          "${rootDir}/data/conf/dovecot/global_sieve_after:/global_sieve/after"
          "${rootDir}/data/assets/templates:/tpls"
          "${rootDir}/data/conf/nginx/:/etc/nginx/conf.d/"
        ];
        extraOptions = [
          # added by me
          "--ip=${IPV4_NETWORK}.202"
          "--dns=${unboundAddr}"
          "--network-alias=phpfpm"
        ];
        environment = {
          inherit TZ IPV4_NETWORK IPV6_NETWORK REDIS_SLAVEOF_IP MASTER REDIS_SLAVEOF_PORT DBNAME DBUSER IMAP_PORT IMAPS_PORT POP_PORT POPS_PORT SIEVE_PORT SUBMISSION_PORT SMTP_PORT SMTPS_PORT;
          LOG_LINES = "9999";
          MAILCOW_HOSTNAME = hostname;
          MAILCOW_PASS_SCHEME = "BLF-CRYPT";
          API_KEY = "invalid";
          API_KEY_READ_ONLY = "invalid";
          API_ALLOW_FROM = "invalid";
          COMPOSE_PROJECT_NAME = "mailcow";
          SKIP_SOLR =
            if lite
            then "y"
            else "n";
          SKIP_CLAMD = "y";
          SKIP_SOGO =
            if lite
            then "y"
            else "n";
          ALLOW_ADMIN_EMAIL_LOGIN = "n";
          DEV_MODE = "n";
          DEMO_MODE = "n";
          WEBAUTHN_ONLY_TRUSTED_VENDORS = "n";
          CLUSTERMODE = "";
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
      };

      sogo-mailcow = {
        image = "mailcow/sogo:1.123";
        volumes = [
          "${rootDir}/data/hooks/sogo:/hooks"
          "${rootDir}/data/conf/sogo/:/etc/sogo/"
          "${rootDir}/data/web/inc/init_db.inc.php:/init_db.inc.php"
          "${rootDir}/data/conf/sogo/custom-favicon.ico:/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo.ico"
          "${rootDir}/data/conf/sogo/custom-theme.js:/usr/lib/GNUstep/SOGo/WebServerResources/js/theme.js"
          "${rootDir}/data/conf/sogo/custom-sogo.js:/usr/lib/GNUstep/SOGo/WebServerResources/js/custom-sogo.js"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
          "${dataDir}/sogo-web:/sogo_web"
          "${dataDir}/sogo-userdata-backup:/sogo_backup"
        ];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--ip=${IPV4_NETWORK}.248"
          "--network-alias=sogo"
        ];
        environment = {
          inherit TZ IPV4_NETWORK REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT MASTER DBNAME DBUSER;
          LOG_LINES = "9999";
          MAILCOW_HOSTNAME = hostname;
          MAILCOW_PASS_SCHEME = "BLF-CRYPT";
          ACL_ANYONE = "disallow";
          ALLOW_ADMIN_EMAIL_LOGIN = "n";
          # in minutes
          SOGO_EXPIRE_SESSION = builtins.toString (60 * 7 * 4 * 6);
          SKIP_SOGO =
            if lite
            then "y"
            else "n";
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
        labels = {
          "ofelia.enabled" = "true";
          "ofelia.job-exec.sogo_sessions.schedule" = "@every 1m";
          "ofelia.job-exec.sogo_sessions.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool -v expire-sessions \${SOGO_EXPIRE_SESSION} || exit 0\"";
          "ofelia.job-exec.sogo_ealarms.schedule" = "@every 1m";
          "ofelia.job-exec.sogo_ealarms.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-ealarms-notify -p /etc/sogo/sieve.creds || exit 0\"";
          "ofelia.job-exec.sogo_eautoreply.schedule" = "@every 5m";
          "ofelia.job-exec.sogo_eautoreply.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool update-autoreply -p /etc/sogo/sieve.creds || exit 0\"";
          "ofelia.job-exec.sogo_backup.schedule" = "@every 24h";
          "ofelia.job-exec.sogo_backup.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool backup /sogo_backup ALL || exit 0\"";
        };
      };

      dovecot-mailcow = {
        image = "mailcow/dovecot:1.28.2";
        dependsOn = ["mysql-mailcow" "netfilter-mailcow"];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--cap-add=NET_BIND_SERVICE"
          "--tty"
          "--ip=${IPV4_NETWORK}.250"
          "--pids-limit=65535"
          "--ulimit=nofile=20000:40000"
          "--network-alias=dovecot"
        ];
        volumes = [
          "${rootDir}/data/hooks/dovecot:/hooks"
          "${rootDir}/data/conf/dovecot:/etc/dovecot"
          "${rootDir}/data/assets/ssl:/etc/ssl/mail/:ro"
          "${rootDir}/data/conf/sogo/:/etc/sogo/"
          "${rootDir}/data/conf/phpfpm/sogo-sso/:/etc/phpfpm/"
          "${dataDir}/vmail:/var/vmail"
          "${dataDir}/vmail-index:/var/vmail_index"
          "${dataDir}/crypt:/mail_crypt/"
          "${rootDir}/data/conf/rspamd/custom/:/etc/rspamd/custom"
          "${rootDir}/data/assets/templates:/templates"
          "${dataDir}/rspamd:/var/lib/rspamd"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
        ];
        environment = {
          inherit TZ IPV4_NETWORK REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT MASTER DBNAME DBUSER MAILDIR_SUB;
          DOVECOT_MASTER_USER = "";
          DOVECOT_MASTER_PASS = "";
          MAILCOW_REPLICA_IP = "";
          DOVEADM_REPLICA_PORT = "";
          LOG_LINES = "9999";
          MAILCOW_HOSTNAME = hostname;
          MAILCOW_PASS_SCHEME = "BLF-CRYPT";
          ALLOW_ADMIN_EMAIL_LOGIN = "n";
          MAILDIR_GC_TIME = "7200";
          ACL_ANYONE = "disallow";
          SKIP_SOLR =
            if lite
            then "y"
            else "n";
          COMPOSE_PROJECT_NAME = "mailcow";
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
        ports = [
          "${IMAP_PORT}:143"
          "${IMAPS_PORT}:993"
          "${POP_PORT}:110"
          "${POPS_PORT}:995"
          "${SIEVE_PORT}:4190"
        ];
        labels = {
          "ofelia.enabled" = "true";
          "ofelia.job-exec.dovecot_imapsync_runner.schedule" = "@every 1m";
          "ofelia.job-exec.dovecot_imapsync_runner.no-overlap" = "true";
          "ofelia.job-exec.dovecot_imapsync_runner.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu nobody /usr/local/bin/imapsync_runner.pl || exit 0\"";
          "ofelia.job-exec.dovecot_trim_logs.schedule" = "@every 1m";
          "ofelia.job-exec.dovecot_trim_logs.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/trim_logs.sh || exit 0\"";
          "ofelia.job-exec.dovecot_quarantine.schedule" = "@every 20m";
          "ofelia.job-exec.dovecot_quarantine.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/quarantine_notify.py || exit 0\"";
          "ofelia.job-exec.dovecot_clean_q_aged.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_clean_q_aged.command" = "/bin/bash -c \"[[ \${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/clean_q_aged.sh || exit 0\"";
          "ofelia.job-exec.dovecot_maildir_gc.schedule" = "@every 30m";
          "ofelia.job-exec.dovecot_maildir_gc.command" = "/bin/bash -c \"source /source_env.sh ; /usr/local/bin/gosu vmail /usr/local/bin/maildir_gc.sh\"";
          "ofelia.job-exec.dovecot_sarules.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_sarules.command" = "/bin/bash -c \"/usr/local/bin/sa-rules.sh\"";
          "ofelia.job-exec.dovecot_fts.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_fts.command" = "/usr/bin/curl http://solr:8983/solr/dovecot-fts/update?optimize=true";
          "ofelia.job-exec.dovecot_repl_health.schedule" = "@every 5m";
          "ofelia.job-exec.dovecot_repl_health.command" = "/bin/bash -c \"/usr/local/bin/gosu vmail /usr/local/bin/repl_health.sh\"";
        };
      };

      postfix-mailcow = {
        image = "mailcow/postfix:1.74";
        # TODO: healthchecks
        dependsOn = ["mysql-mailcow" "unbound-mailcow"];
        volumes = [
          "${rootDir}/data/hooks/postfix:/hooks"
          "${rootDir}/data/conf/postfix:/opt/postfix/conf"
          "${rootDir}/data/assets/ssl:/etc/ssl/mail/:ro"
          "${dataDir}/postfix:/var/spool/postfix"
          "${dataDir}/crypt:/var/lib/zeyple"
          "${dataDir}/rspamd:/var/lib/rspamd"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
        ];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--cap-add=NET_BIND_SERVICE"
          "--ip=${IPV4_NETWORK}.253"
          "--network-alias=postfix"
        ];
        environment = {
          inherit TZ REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT DBNAME DBUSER;
          LOG_LINES = "9999";
          MAILCOW_HOSTNAME = hostname;
          SPAMHAUS_DQS_KEY = "";
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
        ports = [
          "${SMTP_PORT}:25"
          "${SMTPS_PORT}:465"
          "${SUBMISSION_PORT}:587"
        ];
      };

      memcached-mailcow = {
        image = "memcached:alpine";
        environment = {inherit TZ;};
      };

      nginx-mailcow = {
        image = "nginx:mainline-alpine";
        dependsOn = ["sogo-mailcow" "php-fpm-mailcow" "redis-mailcow"];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--network-alias=nginx"
          "--cap-add=NET_RAW"
        ];
        cmd = [
          "/bin/sh"
          "-c"
          ''
            envsubst < /etc/nginx/conf.d/templates/listen_plain.template > /etc/nginx/conf.d/listen_plain.active && \
            envsubst < /etc/nginx/conf.d/templates/listen_ssl.template > /etc/nginx/conf.d/listen_ssl.active && \
            envsubst < /etc/nginx/conf.d/templates/sogo.template > /etc/nginx/conf.d/sogo.active && \
            . /etc/nginx/conf.d/templates/server_name.template.sh > /etc/nginx/conf.d/server_name.active && \
            . /etc/nginx/conf.d/templates/sites.template.sh > /etc/nginx/conf.d/sites.active && \
            . /etc/nginx/conf.d/templates/sogo_eas.template.sh > /etc/nginx/conf.d/sogo_eas.active && \
            nginx -qt && \
            until ping phpfpm -c1 > /dev/null; do sleep 1; done && \
            until ping sogo -c1 > /dev/null; do sleep 1; done && \
            until ping redis -c1 > /dev/null; do sleep 1; done && \
            until ping rspamd -c1 > /dev/null; do sleep 1; done && \
            exec nginx -g 'daemon off;'
          ''
        ];
        environment = {
          inherit TZ IPV4_NETWORK;
          HTTP_PORT = "80";
          HTTPS_PORT = "443";
          MAILCOW_HOSTNAME = hostname;
          SKIP_SOGO =
            if lite
            then "y"
            else "n";
          ALLOW_ADMIN_EMAIL_LOGIN = "n";
          ADDITIONAL_SERVER_NAMES = "";
        };
        volumes = [
          "${rootDir}/data/web:/web:ro"
          "${rootDir}/data/conf/rspamd/dynmaps:/dynmaps:ro"
          "${rootDir}/data/assets/ssl/:/etc/ssl/mail/:ro"
          "${rootDir}/data/conf/nginx/:/etc/nginx/conf.d/"
          "${rootDir}/data/conf/rspamd/meta_exporter:/meta_exporter:ro"
          "${dataDir}/sogo-web:/usr/lib/GNUstep/SOGo/"
        ];
        traefik = {
          host = hostname;
          port = 80;
        };
      };

      netfilter-mailcow = {
        image = "mailcow/netfilter:1.58";
        # TODO: stop_grace_period: 30s
        extraOptions = [
          "--privileged"
        ];
        network = "host";
        environment = {
          inherit TZ IPV4_NETWORK IPV6_NETWORK REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT;
          SNAT_TO_SOURCE = "n";
          SNAT6_TO_SOURCE = "n";
          MAILCOW_REPLICA_IP = "";
          DISABLE_NETFILTER_ISOLATION_RULE = "n";
        };
      };

      watchdog-mailcow = {
        image = "mailcow/watchdog:2.02";
        dependsOn = ["postfix-mailcow" "dovecot-mailcow" "mysql-mailcow" "redis-mailcow"];
        environment = {
          inherit TZ IPV4_NETWORK IPV6_NETWORK REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT DBNAME DBUSER;
          LOG_LINES = "9999";
          USE_WATCHDOG = "y";
          WATCHDOG_NOTIFY_EMAIL = "";
          WATCHDOG_NOTIFY_BAN = "n";
          WATCHDOG_NOTIFY_START = "y";
          WATCHDOG_SUBJECT = "Watchdog ALERT";
          WATCHDOG_NOTIFY_WEBHOOK = "";
          WATCHDOG_NOTIFY_WEBHOOK_BODY = "";
          WATCHDOG_EXTERNAL_CHECKS = "n";
          WATCHDOG_MYSQL_REPLICATION_CHECKS = "n";
          WATCHDOG_VERBOSE = "n";
          MAILCOW_HOSTNAME = hostname;
          COMPOSE_PROJECT_NAME = "mailcow";
          IP_BY_DOCKER_API = "0";
          CHECK_UNBOUND = "1";
          SKIP_CLAMD = "y";
          SKIP_LETS_ENCRYPT = "y";
          SKIP_SOGO =
            if lite
            then "y"
            else "n";
          HTTPS_PORT = "443";
          EXTERNAL_CHECKS_THRESHOLD = "1";
          NGINX_THRESHOLD = "5";
          UNBOUND_THRESHOLD = "5";
          REDIS_THRESHOLD = "5";
          MYSQL_THRESHOLD = "5";
          MYSQL_REPLICATION_THRESHOLD = "1";
          SOGO_THRESHOLD = "3";
          POSTFIX_THRESHOLD = "8";
          CLAMD_THRESHOLD = "15";
          DOVECOT_THRESHOLD = "12";
          DOVECOT_REPL_THRESHOLD = "20";
          PHPFPM_THRESHOLD = "5";
          RATELIMIT_THRESHOLD = "1";
          FAIL2BAN_THRESHOLD = "1";
          ACME_THRESHOLD = "1";
          RSPAMD_THRESHOLD = "5";
          OLEFY_THRESHOLD = "5";
          MAILQ_THRESHOLD = "20";
          MAILQ_CRIT = "30";
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--tmpfs=/tmp"
        ];
        volumes = [
          "${dataDir}/rspamd:/var/lib/rspamd"
          "${dataDir}/mysql-socket:/var/run/mysqld/"
          "${dataDir}/postfix:/var/spool/postfix"
          "${rootDir}/data/assets/ssl:/etc/ssl/mail/:ro"
        ];
      };

      dockerapi-mailcow = {
        image = "mailcow/dockerapi:2.07";
        environment = {
          inherit TZ REDIS_SLAVEOF_IP REDIS_SLAVEOF_PORT;
        };
        environmentFiles = [
          config.sops.secrets."services/mailcow/db_creds".path
        ];
        extraOptions = [
          "--dns=${unboundAddr}"
          "--network-alias=dockerapi"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
      };

      solr-mailcow = {
        image = "mailcow/solr:1.8.2";
        dependsOn = ["netfilter-mailcow"];
        environment = {
          inherit TZ;
          SOLR_HEAP = "1024";
          SKIP_SOLR =
            if lite
            then "y"
            else "n";
        };
        extraOptions = [
          "--network-alias=solr"
        ];
        volumes = [
          "${dataDir}/solr:/opt/solr/server/solr/dovecot-fts/data"
        ];
      };

      olefy-mailcow = {
        image = "mailcow/olefy:1.12";
        environment = {
          inherit TZ;
          OLEFY_BINDADDRESS = "0.0.0.0";
          OLEFY_BINDPORT = "10055";
          OLEFY_TMPDIR = "/tmp";
          OLEFY_PYTHON_PATH = "/usr/bin/python3";
          OLEFY_OLEVBA_PATH = "/usr/bin/olevba";
          OLEFY_LOGLVL = "20";
          OLEFY_MINLENGTH = "500";
          OLEFY_DEL_TMP = "1";
        };
        extraOptions = [
          "--network-alias=olefy"
        ];
      };

      ofelia-mailcow = {
        image = "mcuadros/ofelia:latest";
        dependsOn = ["sogo-mailcow" "dovecot-mailcow"];
        cmd = ["daemon" "--docker"];
        environment = {
          inherit TZ;
        };
        extraOptions = [
          "--network-alias=ofelia"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        labels = {
          "ofelia.enabled" = "true";
        };
      };
    };
  };
  system.activationScripts.mailcow-create-dirs.text = ''
    if [[ ! -d ${rootDir} ]]; then
      ${lib.getExe pkgs.git} clone https://github.com/mailcow/mailcow-dockerized ${rootDir}
      pushd ${rootDir}
      ${lib.getExe pkgs.git} switch -d 2024-04
      ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:4096 -keyout data/assets/ssl-example/key.pem -out data/assets/ssl-example/cert.pem -days 365 -subj "/C=DE/ST=NRW/L=Willich/O=mailcow/OU=mailcow/CN=${hostname}" -sha256 -nodes
      # TODO: configure automatic copy of proper certificates
      mkdir data/assets/ssl/
      cp -n -d data/assets/ssl-example/*.pem data/assets/ssl/
      popd
    fi
    mkdir -p ${dataDir} ${dataDir}/mysql ${dataDir}/mysql-socket ${dataDir}/redis ${dataDir}/rspamd ${dataDir}/sogo-web ${dataDir}/sogo-userdata-backup ${dataDir}/vmail ${dataDir}/vmail-index ${dataDir}/crypt ${dataDir}/postfix ${dataDir}/solr
  '';
}
