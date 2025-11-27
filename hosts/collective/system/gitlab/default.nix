{
  config,
  lib,
  pkgs,
  ...
}: let
  final-gl-port = 8000;
in {
  # TODO: configure smtp
  sops.secrets = lib.mkMerge [
    (lib.genAttrs [
      "gitlab/root"
      "gitlab/secret"
      "gitlab/otp"
      "gitlab/db"
      "gitlab/jws"
      "gitlab/active_record/primary_key"
      "gitlab/active_record/det_key"
      "gitlab/active_record/salt"
      "gitlab/b2/key_id"
      "gitlab/b2/access_key"
      "gitlab/omniauth/authentik/id"
      "gitlab/omniauth/authentik/secret"
    ] (name: {owner = "git";}))
    {
      "gitlab/registry/cert".owner = "docker-registry";
      "gitlab/registry/key".owner = "git";
    }
    (lib.genAttrs [
      "gitlab/runner/docker"
    ] (name: {owner = "gitlab-runner";}))
  ];
  services.gitlab = {
    enable = true;

    packages.gitlab = pkgs.gitlab.overrideAttrs (old: {
      patches =
        old.patches or []
        ++ [
          ./0001-Sane-CI-logs-live-tail-behavior.patch
        ];
    });

    host = "foxlab.dev";
    port = 443;
    https = true;

    user = "git";
    group = "git";
    databaseUsername = "git";

    puma.workers = 4;

    registry = {
      enable = true;
      # actually a noop in the current gitlab module
      port = 5000;
      # TODO: move to registry.foxlab.dev
      externalAddress = "registry.vanutp.dev";
      externalPort = 443;
      certFile = config.sops.secrets."gitlab/registry/cert".path;
      keyFile = config.sops.secrets."gitlab/registry/key".path;
    };

    workhorse.config = {
      object_storage.provider = "AWS";
      object_storage.s3 = {
        aws_access_key_id._secret = config.sops.secrets."gitlab/b2/key_id".path;
        aws_secret_access_key._secret = config.sops.secrets."gitlab/b2/access_key".path;
      };
    };
    extraConfig = {
      gitlab = {
        time_zone = "Europe/Moscow";
        ssh_host = "ssh.foxlab.dev";
        default_theme = 10;
        custom_html_header_tags = ''
          <link rel="stylesheet" href="/custom.css">
          <script defer src="https://zond.vanutp.dev/script.js" data-website-id="9dcd6da5-3225-4f17-86a3-699f82b95e38"></script>
        '';
      };
      # Needed because services.gitlab.registry.externalPort is mandatory,
      # and setting it causes problems when CI is trying to access
      # the registry using the address without the port
      registry.port = null;
      object_store = {
        enabled = true;
        proxy_download = true;
        connection = {
          provider = "AWS";
          aws_access_key_id._secret = config.sops.secrets."gitlab/b2/key_id".path;
          aws_secret_access_key._secret = config.sops.secrets."gitlab/b2/access_key".path;
          region = "eu-central-003";
          endpoint = "https://s3.eu-central-003.backblazeb2.com";
        };
        storage_options.server_side_encryption = "AES256";
        objects = {
          artifacts.enabled = false;
          external_diffs.enabled = false;
          lfs.bucket = "foxlab-lfs";
          uploads.enabled = false;
          packages.enabled = false;
          dependency_proxy.enabled = false;
          terraform_state.enabled = false;
          ci_secure_files.enabled = false;
        };
      };
      omniauth = {
        enabled = true;
        allow_single_sign_on = ["openid_connect"];
        block_auto_created_users = false;
        auto_link_user = ["openid_connect"];
        sync_profile_from_provider = ["openid_connect"];
        auto_sign_in_with_provider = "openid_connect";
        # sync_email_from_provider = "openid_connect";
        # sync_profile_from_provider = ["openid_connect"];
        # sync_profile_attributes = ["email"];
        providers = [
          {
            name = "openid_connect";
            label = "vanutp one";
            args = {
              name = "openid_connect";
              scope = ["openid" "profile" "email"];
              response_type = "code";
              issuer = "https://one.vanutp.dev/application/o/foxlab/";
              discovery = true;
              client_auth_method = "query";
              pkce = true;
              client_options = {
                identifier._secret = config.sops.secrets."gitlab/omniauth/authentik/id".path;
                secret._secret = config.sops.secrets."gitlab/omniauth/authentik/secret".path;
                redirect_uri = "https://foxlab.dev/users/auth/openid_connect/callback";
              };
            };
          }
        ];
      };
    };

    initialRootPasswordFile = config.sops.secrets."gitlab/root".path;
    secrets = {
      secretFile = config.sops.secrets."gitlab/secret".path;
      otpFile = config.sops.secrets."gitlab/otp".path;
      dbFile = config.sops.secrets."gitlab/db".path;
      jwsFile = config.sops.secrets."gitlab/jws".path;
      activeRecordPrimaryKeyFile = config.sops.secrets."gitlab/active_record/primary_key".path;
      activeRecordDeterministicKeyFile = config.sops.secrets."gitlab/active_record/det_key".path;
      activeRecordSaltFile = config.sops.secrets."gitlab/active_record/salt".path;
    };
  };

  # services.anubis = {
  #   package = pkgs-unstable.anubis;
  #   instances.foxlab.settings.TARGET = "unix:/run/gitlab/gitlab-workhorse.socket";
  # };

  services.nginx = {
    # TODO: auto enable in a shared module if there are virtualHosts
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "foxlab.dev" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = final-gl-port;
          }
        ];
        locations."/" = {
          # proxyPass = "http://unix:${config.services.anubis.instances.foxlab.settings.BIND}";
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          extraConfig = ''
            proxy_set_header X-Forwarded-Ssl on;
            client_max_body_size 0;
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };
        locations."= /custom.css" = {
          extraConfig = "add_header Content-Type text/css;";
          return = ''
            200 '
              .header-logged-out-logo, .brand-logo {
                margin-top: -4px;
                margin-bottom: -4px;
                height: unset;
              }
              .header-logged-out-logo:hover, .header-logged-out-logo:focus {
                background-color: rgba(255, 255, 255, 0.24);
              }
              .header-logged-out-logo img, .brand-logo img {
                height: 32px;
              }
              header.header-logged-out {
                background-color: #a02e1c !important;
              }
              .blob-viewer .line-numbers {
                min-width: 66px !important;
              }
              @media (max-width: 768px) {
                .file-holder > .blob-viewer {
                  margin: 0 -16px;
                }
              }
            '
          '';
        };
      };
    };
  };

  vanutp.maskman.entries = [{name = "foxlab.dev";}];
  vanutp.traefik = {
    proxies = [
      {
        host = "registry.vanutp.dev";
        target = "http://127.0.0.1:5000";
      }
      {
        host = "foxlab.dev";
        target = "http://127.0.0.1:${builtins.toString final-gl-port}";
      }
    ];
    extraDynamicConfig = {
      http.routers.git_vanutp_dev = {
        rule = "Host(`git.vanutp.dev`)";
        middlewares = ["git_vanutp_dev"];
        service = "noop@internal";
      };
      http.middlewares.git_vanutp_dev.redirectregex = {
        regex = "^https://git\\.vanutp\\.dev/(.*)";
        replacement = "https://foxlab.dev/\${1}";
      };
    };
  };

  services.gitlab-runner = {
    enable = true;
    settings = {
      concurrent = 10;
    };
    services = {
      docker1 = {
        authenticationTokenConfigFile = config.sops.secrets."gitlab/runner/docker".path;
        dockerImage = "docker:dind-rootless";
        dockerVolumes = [
          "/certs/client"
          "/cache"
        ];
        environmentVariables = {
          GIT_CONFIG_COUNT = "1";
          GIT_CONFIG_KEY_0 = "safe.directory";
          GIT_CONFIG_VALUE_0 = "*";
          DOCKER_TLS_CERTDIR = "/certs";
          FF_NETWORK_PER_BUILD = "1";
        };
        registrationFlags = (
          [
            "--docker-services_privileged true"
          ]
          ++ (map (v: "--docker-allowed-privileged-services ${lib.escapeShellArg v}") [
            "docker.io/library/docker:*-dind-rootless"
            "docker.io/library/docker:dind-rootless"
            "docker:*-dind-rootless"
            "docker:dind-rootless"
          ])
        );
      };
    };
  };

  users.groups.gitlab-runner = {};
  users.users.gitlab-runner = {
    isSystemUser = true;
    group = "gitlab-runner";
  };
  systemd.services.gitlab-runner.serviceConfig = {
    User = "gitlab-runner";
    Group = "gitlab-runner";
  };

  vanutp.backup.backups.gitlab = {
    backupPrepareCommand = ''
      /run/wrappers/bin/sudo -u git /run/current-system/sw/bin/gitlab-rake gitlab:backup:create BACKUP=restic
    '';
    paths = ["/var/gitlab/state/backup/restic_gitlab_backup.tar"];
    extraBackupArgs = ["--compression=off"];
    backupCleanupCommand = "rm /var/gitlab/state/backup/restic_gitlab_backup.tar";
  };

  services.gatus.settings.endpoints = [
    {
      name = "foxlab";
      url = "http://localhost:${builtins.toString final-gl-port}/health_check";
      interval = "5m";
      conditions = [
        "[STATUS] == 200"
        "[BODY] == success"
      ];
    }
  ];
}
