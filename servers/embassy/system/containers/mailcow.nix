# TODO: CURRENTLY UNUSED
{...}: {
  virtualisation.composter.apps.mailcow = {
    networks = {
      mailcow-network = {
        driver = "bridge";
        driver_opts = {"com.docker.network.bridge.name" = "br-mailcow";};
        enable_ipv6 = true;
        ipam = {
          config = [{subnet = "\${IPV4_NETWORK:-172.22.1}.0/24";} {subnet = "\${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}";}];
          driver = "default";
        };
      };
    };
    services = {
      acme-mailcow = {
        depends_on = {
          nginx-mailcow = {condition = "service_started";};
          unbound-mailcow = {condition = "service_healthy";};
        };
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ACME_CONTACT = "\${ACME_CONTACT:-}";
          ADDITIONAL_SAN = "\${ADDITIONAL_SAN}";
          COMPOSE_PROJECT_NAME = "\${COMPOSE_PROJECT_NAME:-mailcow-dockerized}";
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBUSER = "\${DBUSER}";
          DIRECTORY_URL = "\${DIRECTORY_URL:-}";
          ENABLE_SSL_SNI = "\${ENABLE_SSL_SNI:-n}";
          LE_STAGING = "\${LE_STAGING:-n}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          ONLY_MAILCOW_HOSTNAME = "\${ONLY_MAILCOW_HOSTNAME:-n}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SKIP_HTTP_VERIFICATION = "\${SKIP_HTTP_VERIFICATION:-n}";
          SKIP_IP_CHECK = "\${SKIP_IP_CHECK:-n}";
          SKIP_LETS_ENCRYPT = "\${SKIP_LETS_ENCRYPT:-n}";
          SNAT6_TO_SOURCE = "\${SNAT6_TO_SOURCE:-n}";
          SNAT_TO_SOURCE = "\${SNAT_TO_SOURCE:-n}";
          TZ = "\${TZ}";
        };
        image = "mailcow/acme:1.87";
        networks = {mailcow-network = {aliases = ["acme"];};};
        volumes = ["./data/web/.well-known/acme-challenge:/var/www/acme:z" "./data/assets/ssl:/var/lib/acme/:z" "./data/assets/ssl-example:/var/lib/ssl-example/:ro,Z" "mysql-socket-vol-1:/var/run/mysqld/"];
      };
      clamd-mailcow = {
        depends_on = {unbound-mailcow = {condition = "service_healthy";};};
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          SKIP_CLAMD = "\${SKIP_CLAMD:-n}";
          TZ = "\${TZ}";
        };
        image = "mailcow/clamd:1.64";
        networks = {mailcow-network = {aliases = ["clamd"];};};
        volumes = ["./data/conf/clamav/:/etc/clamav/:Z" "clamd-db-vol-1:/var/lib/clamav"];
      };
      dockerapi-mailcow = {
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          DBROOT = "\${DBROOT}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          TZ = "\${TZ}";
        };
        image = "mailcow/dockerapi:2.07";
        networks = {mailcow-network = {aliases = ["dockerapi"];};};
        security_opt = ["label=disable"];
        volumes = ["/var/run/docker.sock:/var/run/docker.sock:ro"];
      };
      dovecot-mailcow = {
        cap_add = ["NET_BIND_SERVICE"];
        depends_on = ["mysql-mailcow" "netfilter-mailcow"];
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ACL_ANYONE = "\${ACL_ANYONE:-disallow}";
          ALLOW_ADMIN_EMAIL_LOGIN = "\${ALLOW_ADMIN_EMAIL_LOGIN:-n}";
          COMPOSE_PROJECT_NAME = "\${COMPOSE_PROJECT_NAME:-mailcow-dockerized}";
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBUSER = "\${DBUSER}";
          DOVEADM_REPLICA_PORT = "\${DOVEADM_REPLICA_PORT:-}";
          DOVECOT_MASTER_PASS = "\${DOVECOT_MASTER_PASS:-}";
          DOVECOT_MASTER_USER = "\${DOVECOT_MASTER_USER:-}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          MAILCOW_PASS_SCHEME = "\${MAILCOW_PASS_SCHEME:-BLF-CRYPT}";
          MAILCOW_REPLICA_IP = "\${MAILCOW_REPLICA_IP:-}";
          MAILDIR_GC_TIME = "\${MAILDIR_GC_TIME:-7200}";
          MAILDIR_SUB = "\${MAILDIR_SUB:-}";
          MASTER = "\${MASTER:-y}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SKIP_SOLR = "\${SKIP_SOLR:-y}";
          TZ = "\${TZ}";
        };
        image = "mailcow/dovecot:1.28.2";
        labels = {
          "ofelia.enabled" = "true";
          "ofelia.job-exec.dovecot_clean_q_aged.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/clean_q_aged.sh || exit 0\"";
          "ofelia.job-exec.dovecot_clean_q_aged.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_fts.command" = "/usr/bin/curl http://solr:8983/solr/dovecot-fts/update?optimize=true";
          "ofelia.job-exec.dovecot_fts.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_imapsync_runner.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu nobody /usr/local/bin/imapsync_runner.pl || exit 0\"";
          "ofelia.job-exec.dovecot_imapsync_runner.no-overlap" = "true";
          "ofelia.job-exec.dovecot_imapsync_runner.schedule" = "@every 1m";
          "ofelia.job-exec.dovecot_maildir_gc.command" = "/bin/bash -c \"source /source_env.sh ; /usr/local/bin/gosu vmail /usr/local/bin/maildir_gc.sh\"";
          "ofelia.job-exec.dovecot_maildir_gc.schedule" = "@every 30m";
          "ofelia.job-exec.dovecot_quarantine.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/quarantine_notify.py || exit 0\"";
          "ofelia.job-exec.dovecot_quarantine.schedule" = "@every 20m";
          "ofelia.job-exec.dovecot_repl_health.command" = "/bin/bash -c \"/usr/local/bin/gosu vmail /usr/local/bin/repl_health.sh\"";
          "ofelia.job-exec.dovecot_repl_health.schedule" = "@every 5m";
          "ofelia.job-exec.dovecot_sarules.command" = "/bin/bash -c \"/usr/local/bin/sa-rules.sh\"";
          "ofelia.job-exec.dovecot_sarules.schedule" = "@every 24h";
          "ofelia.job-exec.dovecot_trim_logs.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu vmail /usr/local/bin/trim_logs.sh || exit 0\"";
          "ofelia.job-exec.dovecot_trim_logs.schedule" = "@every 1m";
        };
        networks = {
          mailcow-network = {
            aliases = ["dovecot"];
            ipv4_address = "\${IPV4_NETWORK:-172.22.1}.250";
          };
        };
        ports = ["\${DOVEADM_PORT:-127.0.0.1:19991}:12345" "\${IMAP_PORT:-143}:143" "\${IMAPS_PORT:-993}:993" "\${POP_PORT:-110}:110" "\${POPS_PORT:-995}:995" "\${SIEVE_PORT:-4190}:4190"];
        tty = true;
        ulimits = {
          nofile = {
            hard = 40000;
            soft = 20000;
          };
          nproc = 65535;
        };
        volumes = ["./data/hooks/dovecot:/hooks:Z" "./data/conf/dovecot:/etc/dovecot:z" "./data/assets/ssl:/etc/ssl/mail/:ro,z" "./data/conf/sogo/:/etc/sogo/:z" "./data/conf/phpfpm/sogo-sso/:/etc/phpfpm/:z" "vmail-vol-1:/var/vmail" "vmail-index-vol-1:/var/vmail_index" "crypt-vol-1:/mail_crypt/" "./data/conf/rspamd/custom/:/etc/rspamd/custom:z" "./data/assets/templates:/templates:z" "rspamd-vol-1:/var/lib/rspamd" "mysql-socket-vol-1:/var/run/mysqld/"];
      };
      memcached-mailcow = {
        environment = {TZ = "\${TZ}";};
        image = "memcached:alpine";
        networks = {mailcow-network = {aliases = ["memcached"];};};
      };
      mysql-mailcow = {
        depends_on = ["unbound-mailcow" "netfilter-mailcow"];
        environment = {
          MYSQL_DATABASE = "\${DBNAME}";
          MYSQL_INITDB_SKIP_TZINFO = "1";
          MYSQL_PASSWORD = "\${DBPASS}";
          MYSQL_ROOT_PASSWORD = "\${DBROOT}";
          MYSQL_USER = "\${DBUSER}";
          TZ = "\${TZ}";
        };
        image = "mariadb:10.5";
        networks = {mailcow-network = {aliases = ["mysql"];};};
        ports = ["\${SQL_PORT:-127.0.0.1:13306}:3306"];
        stop_grace_period = "45s";
        volumes = ["mysql-vol-1:/var/lib/mysql/" "mysql-socket-vol-1:/var/run/mysqld/" "./data/conf/mysql/:/etc/mysql/conf.d/:ro,Z"];
      };
      netfilter-mailcow = {
        environment = {
          DISABLE_NETFILTER_ISOLATION_RULE = "\${DISABLE_NETFILTER_ISOLATION_RULE:-n}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          IPV6_NETWORK = "\${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}";
          MAILCOW_REPLICA_IP = "\${MAILCOW_REPLICA_IP:-}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SNAT6_TO_SOURCE = "\${SNAT6_TO_SOURCE:-n}";
          SNAT_TO_SOURCE = "\${SNAT_TO_SOURCE:-n}";
          TZ = "\${TZ}";
        };
        image = "mailcow/netfilter:1.57";
        network_mode = "host";
        privileged = true;
        stop_grace_period = "30s";
        volumes = ["/lib/modules:/lib/modules:ro"];
      };
      nginx-mailcow = {
        command = "/bin/sh -c \"envsubst < /etc/nginx/conf.d/templates/listen_plain.template > /etc/nginx/conf.d/listen_plain.active && envsubst < /etc/nginx/conf.d/templates/listen_ssl.template > /etc/nginx/conf.d/listen_ssl.active && envsubst < /etc/nginx/conf.d/templates/sogo.template > /etc/nginx/conf.d/sogo.active && . /etc/nginx/conf.d/templates/server_name.template.sh > /etc/nginx/conf.d/server_name.active && . /etc/nginx/conf.d/templates/sites.template.sh > /etc/nginx/conf.d/sites.active && . /etc/nginx/conf.d/templates/sogo_eas.template.sh > /etc/nginx/conf.d/sogo_eas.active && nginx -qt && until ping phpfpm -c1 > /dev/null; do sleep 1; done && until ping sogo -c1 > /dev/null; do sleep 1; done && until ping redis -c1 > /dev/null; do sleep 1; done && until ping rspamd -c1 > /dev/null; do sleep 1; done && exec nginx -g 'daemon off;'\"";
        depends_on = ["sogo-mailcow" "php-fpm-mailcow" "redis-mailcow"];
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ADDITIONAL_SERVER_NAMES = "\${ADDITIONAL_SERVER_NAMES:-}";
          ALLOW_ADMIN_EMAIL_LOGIN = "\${ALLOW_ADMIN_EMAIL_LOGIN:-n}";
          HTTPS_PORT = "\${HTTPS_PORT:-443}";
          HTTP_PORT = "\${HTTP_PORT:-80}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          SKIP_SOGO = "\${SKIP_SOGO:-n}";
          TZ = "\${TZ}";
        };
        image = "nginx:mainline-alpine";
        networks = {mailcow-network = {aliases = ["nginx"];};};
        ports = ["\${HTTPS_BIND:-}:\${HTTPS_PORT:-443}:\${HTTPS_PORT:-443}" "\${HTTP_BIND:-}:\${HTTP_PORT:-80}:\${HTTP_PORT:-80}"];
        volumes = ["./data/web:/web:ro,z" "./data/conf/rspamd/dynmaps:/dynmaps:ro,z" "./data/assets/ssl/:/etc/ssl/mail/:ro,z" "./data/conf/nginx/:/etc/nginx/conf.d/:z" "./data/conf/rspamd/meta_exporter:/meta_exporter:ro,z" "sogo-web-vol-1:/usr/lib/GNUstep/SOGo/"];
      };
      ofelia-mailcow = {
        command = "daemon --docker";
        depends_on = ["sogo-mailcow" "dovecot-mailcow"];
        environment = {TZ = "\${TZ}";};
        image = "mcuadros/ofelia:latest";
        labels = {"ofelia.enabled" = "true";};
        networks = {mailcow-network = {aliases = ["ofelia"];};};
        security_opt = ["label=disable"];
        volumes = ["/var/run/docker.sock:/var/run/docker.sock:ro"];
      };
      olefy-mailcow = {
        environment = {
          OLEFY_BINDADDRESS = "0.0.0.0";
          OLEFY_BINDPORT = "10055";
          OLEFY_DEL_TMP = "1";
          OLEFY_LOGLVL = "20";
          OLEFY_MINLENGTH = "500";
          OLEFY_OLEVBA_PATH = "/usr/bin/olevba";
          OLEFY_PYTHON_PATH = "/usr/bin/python3";
          OLEFY_TMPDIR = "/tmp";
          TZ = "\${TZ}";
        };
        image = "mailcow/olefy:1.12";
        networks = {mailcow-network = {aliases = ["olefy"];};};
      };
      php-fpm-mailcow = {
        command = "php-fpm -d date.timezone=\${TZ} -d expose_php=0";
        depends_on = ["redis-mailcow"];
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ALLOW_ADMIN_EMAIL_LOGIN = "\${ALLOW_ADMIN_EMAIL_LOGIN:-n}";
          API_ALLOW_FROM = "\${API_ALLOW_FROM:-invalid}";
          API_KEY = "\${API_KEY:-invalid}";
          API_KEY_READ_ONLY = "\${API_KEY_READ_ONLY:-invalid}";
          CLUSTERMODE = "\${CLUSTERMODE:-}";
          COMPOSE_PROJECT_NAME = "\${COMPOSE_PROJECT_NAME:-mailcow-dockerized}";
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBUSER = "\${DBUSER}";
          DEMO_MODE = "\${DEMO_MODE:-n}";
          DEV_MODE = "\${DEV_MODE:-n}";
          IMAPS_PORT = "\${IMAPS_PORT:-993}";
          IMAP_PORT = "\${IMAP_PORT:-143}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          IPV6_NETWORK = "\${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          MAILCOW_PASS_SCHEME = "\${MAILCOW_PASS_SCHEME:-BLF-CRYPT}";
          MASTER = "\${MASTER:-y}";
          POPS_PORT = "\${POPS_PORT:-995}";
          POP_PORT = "\${POP_PORT:-110}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SIEVE_PORT = "\${SIEVE_PORT:-4190}";
          SKIP_CLAMD = "\${SKIP_CLAMD:-n}";
          SKIP_SOGO = "\${SKIP_SOGO:-n}";
          SKIP_SOLR = "\${SKIP_SOLR:-y}";
          SMTPS_PORT = "\${SMTPS_PORT:-465}";
          SMTP_PORT = "\${SMTP_PORT:-25}";
          SUBMISSION_PORT = "\${SUBMISSION_PORT:-587}";
          TZ = "\${TZ}";
          WEBAUTHN_ONLY_TRUSTED_VENDORS = "\${WEBAUTHN_ONLY_TRUSTED_VENDORS:-n}";
        };
        image = "mailcow/phpfpm:1.87";
        networks = {mailcow-network = {aliases = ["phpfpm"];};};
        volumes = ["./data/hooks/phpfpm:/hooks:Z" "./data/web:/web:z" "./data/conf/rspamd/dynmaps:/dynmaps:ro,z" "./data/conf/rspamd/custom/:/rspamd_custom_maps:z" "rspamd-vol-1:/var/lib/rspamd" "mysql-socket-vol-1:/var/run/mysqld/" "./data/conf/sogo/:/etc/sogo/:z" "./data/conf/rspamd/meta_exporter:/meta_exporter:ro,z" "./data/conf/phpfpm/sogo-sso/:/etc/sogo-sso/:z" "./data/conf/phpfpm/php-fpm.d/pools.conf:/usr/local/etc/php-fpm.d/z-pools.conf:Z" "./data/conf/phpfpm/php-conf.d/opcache-recommended.ini:/usr/local/etc/php/conf.d/opcache-recommended.ini:Z" "./data/conf/phpfpm/php-conf.d/upload.ini:/usr/local/etc/php/conf.d/upload.ini:Z" "./data/conf/phpfpm/php-conf.d/other.ini:/usr/local/etc/php/conf.d/zzz-other.ini:Z" "./data/conf/dovecot/global_sieve_before:/global_sieve/before:z" "./data/conf/dovecot/global_sieve_after:/global_sieve/after:z" "./data/assets/templates:/tpls:z" "./data/conf/nginx/:/etc/nginx/conf.d/:z"];
      };
      postfix-mailcow = {
        cap_add = ["NET_BIND_SERVICE"];
        depends_on = {
          mysql-mailcow = {condition = "service_started";};
          unbound-mailcow = {condition = "service_healthy";};
        };
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBUSER = "\${DBUSER}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SPAMHAUS_DQS_KEY = "\${SPAMHAUS_DQS_KEY:-}";
          TZ = "\${TZ}";
        };
        image = "mailcow/postfix:1.74";
        networks = {
          mailcow-network = {
            aliases = ["postfix"];
            ipv4_address = "\${IPV4_NETWORK:-172.22.1}.253";
          };
        };
        ports = ["\${SMTP_PORT:-25}:25" "\${SMTPS_PORT:-465}:465" "\${SUBMISSION_PORT:-587}:587"];
        volumes = ["./data/hooks/postfix:/hooks:Z" "./data/conf/postfix:/opt/postfix/conf:z" "./data/assets/ssl:/etc/ssl/mail/:ro,z" "postfix-vol-1:/var/spool/postfix" "crypt-vol-1:/var/lib/zeyple" "rspamd-vol-1:/var/lib/rspamd" "mysql-socket-vol-1:/var/run/mysqld/"];
      };
      redis-mailcow = {
        depends_on = ["netfilter-mailcow"];
        environment = {TZ = "\${TZ}";};
        image = "redis:7-alpine";
        networks = {
          mailcow-network = {
            aliases = ["redis"];
            ipv4_address = "\${IPV4_NETWORK:-172.22.1}.249";
          };
        };
        ports = ["\${REDIS_PORT:-127.0.0.1:7654}:6379"];
        sysctls = ["net.core.somaxconn=4096"];
        volumes = ["redis-vol-1:/data/"];
      };
      rspamd-mailcow = {
        depends_on = ["dovecot-mailcow"];
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          IPV6_NETWORK = "\${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          TZ = "\${TZ}";
        };
        hostname = "rspamd";
        image = "mailcow/rspamd:1.95";
        networks = {mailcow-network = {aliases = ["rspamd"];};};
        stop_grace_period = "30s";
        volumes = ["./data/hooks/rspamd:/hooks:Z" "./data/conf/rspamd/custom/:/etc/rspamd/custom:z" "./data/conf/rspamd/override.d/:/etc/rspamd/override.d:Z" "./data/conf/rspamd/local.d/:/etc/rspamd/local.d:Z" "./data/conf/rspamd/plugins.d/:/etc/rspamd/plugins.d:Z" "./data/conf/rspamd/lua/:/etc/rspamd/lua/:ro,Z" "./data/conf/rspamd/rspamd.conf.local:/etc/rspamd/rspamd.conf.local:Z" "./data/conf/rspamd/rspamd.conf.override:/etc/rspamd/rspamd.conf.override:Z" "rspamd-vol-1:/var/lib/rspamd"];
      };
      sogo-mailcow = {
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ACL_ANYONE = "\${ACL_ANYONE:-disallow}";
          ALLOW_ADMIN_EMAIL_LOGIN = "\${ALLOW_ADMIN_EMAIL_LOGIN:-n}";
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBUSER = "\${DBUSER}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          MAILCOW_PASS_SCHEME = "\${MAILCOW_PASS_SCHEME:-BLF-CRYPT}";
          MASTER = "\${MASTER:-y}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          SKIP_SOGO = "\${SKIP_SOGO:-n}";
          SOGO_EXPIRE_SESSION = "\${SOGO_EXPIRE_SESSION:-480}";
          TZ = "\${TZ}";
        };
        image = "mailcow/sogo:1.122.1";
        labels = {
          "ofelia.enabled" = "true";
          "ofelia.job-exec.sogo_backup.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool backup /sogo_backup ALL || exit 0\"";
          "ofelia.job-exec.sogo_backup.schedule" = "@every 24h";
          "ofelia.job-exec.sogo_ealarms.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-ealarms-notify -p /etc/sogo/sieve.creds || exit 0\"";
          "ofelia.job-exec.sogo_ealarms.schedule" = "@every 1m";
          "ofelia.job-exec.sogo_eautoreply.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool update-autoreply -p /etc/sogo/sieve.creds || exit 0\"";
          "ofelia.job-exec.sogo_eautoreply.schedule" = "@every 5m";
          "ofelia.job-exec.sogo_sessions.command" = "/bin/bash -c \"[[ $\${MASTER} == y ]] && /usr/local/bin/gosu sogo /usr/sbin/sogo-tool -v expire-sessions $\${SOGO_EXPIRE_SESSION} || exit 0\"";
          "ofelia.job-exec.sogo_sessions.schedule" = "@every 1m";
        };
        networks = {
          mailcow-network = {
            aliases = ["sogo"];
            ipv4_address = "\${IPV4_NETWORK:-172.22.1}.248";
          };
        };
        volumes = ["./data/hooks/sogo:/hooks:Z" "./data/conf/sogo/:/etc/sogo/:z" "./data/web/inc/init_db.inc.php:/init_db.inc.php:z" "./data/conf/sogo/custom-favicon.ico:/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo.ico:z" "./data/conf/sogo/custom-theme.js:/usr/lib/GNUstep/SOGo/WebServerResources/js/theme.js:z" "./data/conf/sogo/custom-sogo.js:/usr/lib/GNUstep/SOGo/WebServerResources/js/custom-sogo.js:z" "mysql-socket-vol-1:/var/run/mysqld/" "sogo-web-vol-1:/sogo_web" "sogo-userdata-backup-vol-1:/sogo_backup"];
      };
      solr-mailcow = {
        depends_on = ["netfilter-mailcow"];
        environment = {
          SKIP_SOLR = "\${SKIP_SOLR:-y}";
          SOLR_HEAP = "\${SOLR_HEAP:-1024}";
          TZ = "\${TZ}";
        };
        image = "mailcow/solr:1.8.2";
        networks = {mailcow-network = {aliases = ["solr"];};};
        ports = ["\${SOLR_PORT:-127.0.0.1:18983}:8983"];
        volumes = ["solr-vol-1:/opt/solr/server/solr/dovecot-fts/data"];
      };
      unbound-mailcow = {
        environment = {
          SKIP_UNBOUND_HEALTHCHECK = "\${SKIP_UNBOUND_HEALTHCHECK:-n}";
          TZ = "\${TZ}";
        };
        image = "mailcow/unbound:1.21";
        networks = {
          mailcow-network = {
            aliases = ["unbound"];
            ipv4_address = "\${IPV4_NETWORK:-172.22.1}.254";
          };
        };
        tty = true;
        volumes = ["./data/hooks/unbound:/hooks:Z" "./data/conf/unbound/unbound.conf:/etc/unbound/unbound.conf:ro,Z"];
      };
      watchdog-mailcow = {
        depends_on = ["postfix-mailcow" "dovecot-mailcow" "mysql-mailcow" "acme-mailcow" "redis-mailcow"];
        dns = ["\${IPV4_NETWORK:-172.22.1}.254"];
        environment = {
          ACME_THRESHOLD = "\${ACME_THRESHOLD:-1}";
          CHECK_UNBOUND = "\${CHECK_UNBOUND:-1}";
          CLAMD_THRESHOLD = "\${CLAMD_THRESHOLD:-15}";
          COMPOSE_PROJECT_NAME = "\${COMPOSE_PROJECT_NAME:-mailcow-dockerized}";
          DBNAME = "\${DBNAME}";
          DBPASS = "\${DBPASS}";
          DBROOT = "\${DBROOT}";
          DBUSER = "\${DBUSER}";
          DOVECOT_REPL_THRESHOLD = "\${DOVECOT_REPL_THRESHOLD:-20}";
          DOVECOT_THRESHOLD = "\${DOVECOT_THRESHOLD:-12}";
          EXTERNAL_CHECKS_THRESHOLD = "\${EXTERNAL_CHECKS_THRESHOLD:-1}";
          FAIL2BAN_THRESHOLD = "\${FAIL2BAN_THRESHOLD:-1}";
          HTTPS_PORT = "\${HTTPS_PORT:-443}";
          IPV4_NETWORK = "\${IPV4_NETWORK:-172.22.1}";
          IPV6_NETWORK = "\${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}";
          IP_BY_DOCKER_API = "\${IP_BY_DOCKER_API:-0}";
          LOG_LINES = "\${LOG_LINES:-9999}";
          MAILCOW_HOSTNAME = "\${MAILCOW_HOSTNAME}";
          MAILQ_CRIT = "\${MAILQ_CRIT:-30}";
          MAILQ_THRESHOLD = "\${MAILQ_THRESHOLD:-20}";
          MYSQL_REPLICATION_THRESHOLD = "\${MYSQL_REPLICATION_THRESHOLD:-1}";
          MYSQL_THRESHOLD = "\${MYSQL_THRESHOLD:-5}";
          NGINX_THRESHOLD = "\${NGINX_THRESHOLD:-5}";
          OLEFY_THRESHOLD = "\${OLEFY_THRESHOLD:-5}";
          PHPFPM_THRESHOLD = "\${PHPFPM_THRESHOLD:-5}";
          POSTFIX_THRESHOLD = "\${POSTFIX_THRESHOLD:-8}";
          RATELIMIT_THRESHOLD = "\${RATELIMIT_THRESHOLD:-1}";
          REDIS_SLAVEOF_IP = "\${REDIS_SLAVEOF_IP:-}";
          REDIS_SLAVEOF_PORT = "\${REDIS_SLAVEOF_PORT:-}";
          REDIS_THRESHOLD = "\${REDIS_THRESHOLD:-5}";
          RSPAMD_THRESHOLD = "\${RSPAMD_THRESHOLD:-5}";
          SKIP_CLAMD = "\${SKIP_CLAMD:-n}";
          SKIP_LETS_ENCRYPT = "\${SKIP_LETS_ENCRYPT:-n}";
          SKIP_SOGO = "\${SKIP_SOGO:-n}";
          SOGO_THRESHOLD = "\${SOGO_THRESHOLD:-3}";
          TZ = "\${TZ}";
          UNBOUND_THRESHOLD = "\${UNBOUND_THRESHOLD:-5}";
          USE_WATCHDOG = "\${USE_WATCHDOG:-n}";
          WATCHDOG_EXTERNAL_CHECKS = "\${WATCHDOG_EXTERNAL_CHECKS:-n}";
          WATCHDOG_MYSQL_REPLICATION_CHECKS = "\${WATCHDOG_MYSQL_REPLICATION_CHECKS:-n}";
          WATCHDOG_NOTIFY_BAN = "\${WATCHDOG_NOTIFY_BAN:-y}";
          WATCHDOG_NOTIFY_EMAIL = "\${WATCHDOG_NOTIFY_EMAIL:-}";
          WATCHDOG_NOTIFY_START = "\${WATCHDOG_NOTIFY_START:-y}";
          WATCHDOG_NOTIFY_WEBHOOK = "\${WATCHDOG_NOTIFY_WEBHOOK:-}";
          WATCHDOG_NOTIFY_WEBHOOK_BODY = "\${WATCHDOG_NOTIFY_WEBHOOK_BODY:-}";
          WATCHDOG_SUBJECT = "\${WATCHDOG_SUBJECT:-Watchdog ALERT}";
          WATCHDOG_VERBOSE = "\${WATCHDOG_VERBOSE:-n}";
        };
        image = "mailcow/watchdog:2.02";
        networks = {mailcow-network = {aliases = ["watchdog"];};};
        tmpfs = ["/tmp"];
        volumes = ["rspamd-vol-1:/var/lib/rspamd" "mysql-socket-vol-1:/var/run/mysqld/" "postfix-vol-1:/var/spool/postfix" "./data/assets/ssl:/etc/ssl/mail/:ro,z"];
      };
    };
    volumes = {
      clamd-db-vol-1 = {};
      crypt-vol-1 = {};
      mysql-socket-vol-1 = {};
      mysql-vol-1 = {};
      postfix-vol-1 = {};
      redis-vol-1 = {};
      rspamd-vol-1 = {};
      sogo-userdata-backup-vol-1 = {};
      sogo-web-vol-1 = {};
      solr-vol-1 = {};
      vmail-index-vol-1 = {};
      vmail-vol-1 = {};
    };
  };
}
