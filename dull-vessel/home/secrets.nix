{
  inputs,
  config,
  ...
}: {
  # TODO: move boilerplate to mkSystem
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = ./secrets.yml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.".pypirc" = {
      # https://github.com/Mic92/sops-nix/issues/423
      path = "${config.home.homeDirectory}/.pypirc";
    };
  };
}
