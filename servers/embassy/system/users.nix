{
  pkgs,
  common,
  config,
  ...
}: {
  system.activationScripts.chown-fox-ssh-dir.text = ''
    ssh_dir=${config.users.users.fox.home}/.ssh
    mkdir -p $ssh_dir
    chown fox:users $ssh_dir
    chmod 0700 $ssh_dir
  '';
  sops.secrets."privkey" = {
    owner = "fox";
    group = "users";
    mode = "0600";
    path = "${config.users.users.fox.home}/.ssh/id_rsa";
  };

  programs.fish.enable = true;

  users.users = builtins.listToAttrs (
    map
    (user: {
      name = user.name;
      value = {
        isNormalUser = true;
        shell = user.shell;
        openssh.authorizedKeys.keys = [
          common.constants.pubkeys.embassy
          common.constants.pubkeys.main
        ];
        linger = true;
      };
    })
    [
      {
        name = "liferooter";
        shell = pkgs.nushell;
      }
      {
        name = "ntonee";
        shell = pkgs.fish;
      }
      {
        name = "tmat";
        shell = pkgs.zsh;
      }
    ]
  );
}
