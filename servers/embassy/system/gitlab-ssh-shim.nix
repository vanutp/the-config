{
  config,
  pkgs,
  ...
}: let
  # TODO: remove StrictHostKeyChecking=no
  gitlabShell = pkgs.writeShellScript "gitlab-shell" ''
    ssh -o StrictHostKeyChecking=no -p 2222 git@10.1.0.4 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
  '';
in {
  systemd.tmpfiles.rules = [
    "L+ /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell - - - - ${gitlabShell}"
  ];
  users.users.git.isNormalUser = true;
  system.activationScripts.gitlab-ssh-shim.text = ''
    ssh_dir=${config.users.users.git.home}/.ssh
    mkdir -p $ssh_dir
    chown git:users $ssh_dir
    chmod 0700 $ssh_dir

    s4_pubkey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWhSVGxnvk+4QVHf8BHKGrly9RCv3yjkCrD8jzjAUKr+7Mk/f0ptaZt+qnqdfAEH39qQm7rep+BNb6XuxbTAiw5HDBaXJOso5fdAoc62qW5gtXj23P6PiaZaDqlycP+G5ruyI91TTVTVBC4qxDIbHJ8AuWMf1y0ORDA/5fAnoAJlBRZ0tkLDjvm92mX/BMDygs0XI2/jMRd1Q/kJzbPd/parYI6cQQ8h4AG6FljZhvIaWY/FPjgwZTY+wF+HGdRIzYLgeFrJltlLwJP7/5sA/bRFO6CDEgsZxNvvwJ3Iawo7IukrwpqErTvjj16l3SSsxc5L5w0OFgt44UnLIDaEx5iAxHKeInNC2a0rJoZp7hDXpZWQozCZOwnicsBAdUq+rjDMiu382V4kd1sNUJNYKXy/QmW6BLCYlKAOZwlAOkZFWF8czQYrRnttmeCSzPOQ98e1Cr/Z57bpq1/s1DD92A3AQ5CjTudu2TokFkFEVU5HqtVpfDVZcXVfR+KDj2UiM= git@s4'
    authorized_keys_file=$ssh_dir/authorized_keys
    if [[ ! -f $authorized_keys_file ]]; then
      echo "$s4_pubkey" > $authorized_keys_file
      chown git:users $authorized_keys_file
      chmod 0600 $authorized_keys_file
    fi
  '';
  sops.secrets."git_privkey" = {
    owner = "git";
    group = "users";
    mode = "0600";
    path = "${config.users.users.git.home}/.ssh/id_rsa";
  };
}
