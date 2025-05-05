{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  gitUpdater,
}:
buildGoModule rec {
  pname = "oh-my-posh";
  version = "25.21.0";

  src = fetchFromGitHub {
    owner = "jandedobbeleer";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-0TLAAJIdvO/CnGAG4TN3C54T/RTpjGqNx/oLEsuvWzg=";
  };

  vendorHash = "sha256-8vc+PfXX+A4+4almazrRIMHd169IQqE8rCaa2aCmB2A=";

  sourceRoot = "source/src";

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jandedobbeleer/oh-my-posh/src/build.Version=${version}"
    "-X github.com/jandedobbeleer/oh-my-posh/src/build.Date=1970-01-01T00:00:00Z"
  ];

  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];

  postPatch = ''
    # these tests requires internet access
    rm image/image_test.go config/migrate_glyphs_test.go upgrade/notice_test.go segments/upgrade_test.go
  '';

  postInstall = ''
    mv $out/bin/{src,oh-my-posh}
    mkdir -p $out/share/oh-my-posh
    cp -r $src/themes $out/share/oh-my-posh/
  '';

  passthru.updateScript = gitUpdater {rev-prefix = "v";};

  meta = {
    description = "Prompt theme engine for any shell";
    mainProgram = "oh-my-posh";
    homepage = "https://ohmyposh.dev";
    changelog = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      lucperkins
      urandom
    ];
  };
}
