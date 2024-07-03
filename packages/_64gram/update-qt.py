#!/usr/bin/env python
import os
import httpx
import subprocess
import json
from pathlib import Path

REPO_NAME = 'desktop-app/patches'
QTBASE_DIR = 'qtbase_6.7.2'
QTWAYLAND_DIR = 'qtwayland_6.7.2'
OUT_FILE = Path(__file__).parent / 'patched-qt.nix'
TEMPLATE = """
# Generated by update-qt.py
# Do not modify
pkgs: let
  repository = pkgs.fetchFromGitHub {
    owner = "{{REPO_OWNER}}";
    repo = "{{REPO_NAME}}";
    rev = "{{REPO_REV}}";
    hash = "{{REPO_HASH}}";
  };
  qtbase = pkgs.kdePackages.qtbase.overrideAttrs (orig: {
    patches =
      orig.patches
      ++ [
        {{QTBASE_PATCHES}}
      ];
  });
  qtshadertools = pkgs.kdePackages.qtshadertools.override {inherit qtbase;};
  qtlanguageserver = pkgs.kdePackages.qtlanguageserver.override {inherit qtbase;};
  qtdeclarative = pkgs.kdePackages.qtdeclarative.override {inherit qtbase qtlanguageserver qtshadertools;};
in [
  qtbase
  (pkgs.kdePackages.qtsvg.override {inherit qtbase;})
  (pkgs.kdePackages.qtimageformats.override {inherit qtbase;})
  ((pkgs.kdePackages.qtwayland.overrideAttrs {
      patches = [
        {{QTWAYLAND_PATCHES}}
      ];
    })
    .override {inherit qtbase qtdeclarative;})
]
""".strip()
PATCH_TEMPLATE = """
(pkgs.fetchpatch {
  url = "{{URL}}";
  hash = "{{HASH}}";
})
""".strip()


def get_patches(repo_dir: Path, in_repo_dir: str):
    files = os.listdir(repo_dir / in_repo_dir)
    result = []
    for file in files:
        result.append(f'"${{repository}}/{in_repo_dir}/{file}"')
    return '\n'.join(result)
        


latest_sha = httpx.get(
    f'https://api.github.com/repos/{REPO_NAME}/commits?per_page=1'
).json()[0]['sha']
repo_url = f'https://github.com/{REPO_NAME}'
prefetched = json.loads(
    subprocess.check_output(
        ['nix', 'run', 'nixpkgs#nix-prefetch-git', '--', repo_url, latest_sha]
    ).decode()
)
prefetched_hash = prefetched['hash']
prefetched_path = Path(prefetched['path'])
qtbase_patches = get_patches(prefetched_path, QTBASE_DIR)
qtwayland_patches = get_patches(prefetched_path, QTWAYLAND_DIR)


result = (
    TEMPLATE.replace('{{QTBASE_PATCHES}}', qtbase_patches)
    .replace('{{QTWAYLAND_PATCHES}}', qtwayland_patches)
    .replace('{{REPO_OWNER}}', REPO_NAME.split('/')[0])
    .replace('{{REPO_NAME}}', REPO_NAME.split('/')[1])
    .replace('{{REPO_REV}}', latest_sha)
    .replace('{{REPO_HASH}}', prefetched_hash)
)
result = subprocess.check_output(['alejandra', '-q'], input=result.encode()).decode()

OUT_FILE.write_text(result)
