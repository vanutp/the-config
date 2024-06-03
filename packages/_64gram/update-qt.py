#!/usr/bin/env python
import httpx
import subprocess
import json
from pathlib import Path

REPO_NAME = 'desktop-app/patches'
QTBASE_DIR = 'qtbase_6.7.1'
QTWAYLAND_DIR = 'qtwayland_6.7.1'
OUT_FILE = Path(__file__).parent / 'patched-qt.nix'
TEMPLATE = '''
# Generated by update-qt.py
# Do not modify
pkgs: let
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
'''.strip()
PATCH_TEMPLATE = '''
(pkgs.fetchpatch {
  url = "{{URL}}";
  hash = "{{HASH}}";
})
'''.strip()


def get_patches(github_files):
    result = []
    for file in github_files:
        url = file['download_url']
        nix_hash = json.loads(
            subprocess.check_output(['nix', 'store', 'prefetch-file', '--json', url]).decode()
        )['hash']
        patch_el = PATCH_TEMPLATE.replace('{{URL}}', url).replace('{{HASH}}', nix_hash)
        result.append(patch_el)
    return '\n'.join(result)


latest_sha = httpx.get(f'https://api.github.com/repos/{REPO_NAME}/commits?per_page=1').json()[0]['sha']
base_url = f'https://api.github.com/repos/{REPO_NAME}/contents/'
query_params = {'ref': latest_sha}
qtbase_patches = get_patches(httpx.get(base_url + QTBASE_DIR, params=query_params).json())
qtwayland_patches = get_patches(httpx.get(base_url + QTWAYLAND_DIR, params=query_params).json())

result = TEMPLATE.replace('{{QTBASE_PATCHES}}', qtbase_patches).replace('{{QTWAYLAND_PATCHES}}', qtwayland_patches)
result = subprocess.check_output(['alejandra', '-q'], input=result.encode()).decode()

OUT_FILE.write_text(result)