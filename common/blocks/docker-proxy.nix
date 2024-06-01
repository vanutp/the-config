{pkgs, ...}: {
  environment.etc."containers/registries.conf".source = (pkgs.formats.toml {}).generate "registries.conf" {
    registry = [
      {
        location = "docker.io";
        mirror = [
          {
            location = "dockerio.vanutp.dev";
          }
        ];
      }
      {
        location = "quay.io";
      }
    ];
  };
}
