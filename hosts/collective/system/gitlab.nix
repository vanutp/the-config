{
  config,
  lib,
  pkgs,
  ...
}: {
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
      "gitlab/omniauth/github/id"
      "gitlab/omniauth/github/secret"
      "gitlab/omniauth/gitlab/id"
      "gitlab/omniauth/gitlab/secret"
      "gitlab/omniauth/google/id"
      "gitlab/omniauth/google/secret"
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
        allow_single_sign_on = ["github" "gitlab" "google_oauth2"];
        block_auto_created_users = false;
        auto_link_user = ["github" "gitlab" "google_oauth2"];
        external_providers = ["github" "gitlab" "google_oauth2"];
        providers = [
          {
            name = "github";
            app_id = config.sops.secrets."gitlab/omniauth/github/id".path;
            app_secret = config.sops.secrets."gitlab/omniauth/github/secret".path;
            args.scope = ["user:email"];
          }
          {
            name = "gitlab";
            app_id = config.sops.secrets."gitlab/omniauth/gitlab/id".path;
            app_secret = config.sops.secrets."gitlab/omniauth/gitlab/secret".path;
            args.scope = ["read_user"];
          }
          {
            name = "google_oauth2";
            app_id = config.sops.secrets."gitlab/omniauth/google/id".path;
            app_secret = config.sops.secrets."gitlab/omniauth/google/secret".path;
            args = {
              access_type = "offline";
              approval_prompt = "";
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

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = let
      listen = [
        {
          addr = "127.0.0.1";
          port = 8000;
        }
      ];
    in {
      "foxlab.dev" = {
        inherit listen;
        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          extraConfig = ''
            proxy_set_header X-Forwarded-Ssl on;
            client_max_body_size 1g;
            sub_filter '</head>' '
              <link rel="stylesheet" href="/custom.css">
              <script defer src="https://zond.vanutp.dev/script.js" data-website-id="9dcd6da5-3225-4f17-86a3-699f82b95e38"></script>
              </head>
            ';
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
                [data-testid="blob-viewer-file-content"] {
                  margin: 0 -16px;
                }
              }
            '
          '';
        };
      };
      "git.vanutp.dev" = {
        inherit listen;
        locations."/".return = "302 https://foxlab.dev$request_uri";
      };
    };
  };

  vanutp.traefik.proxies = [
    {
      host = "git.vanutp.dev";
      target = "http://127.0.0.1:8000";
    }
    {
      host = "registry.vanutp.dev";
      target = "http://127.0.0.1:5000";
    }
    {
      host = "foxlab.dev";
      target = "http://127.0.0.1:8000";
    }
  ];

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
}
