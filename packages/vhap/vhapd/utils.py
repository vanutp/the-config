import os
from pathlib import Path
import shutil
from authlib.jose import JsonWebToken

from vhapd.config import config

jwt_hs256 = JsonWebToken(algorithms=['HS256'])

VHAP_DIR = Path('/srv/vhap')
VHAP_DIR.mkdir(parents=True, exist_ok=True)
CREDS_DIR = VHAP_DIR / '_credentials'
MANAGED_LABEL_KEY = 'dev.vanutp.composter.managed'

NIX_PATH = shutil.which('nix')
if not NIX_PATH:
    raise RuntimeError('nix is not installed')
DOCKER_PATH = shutil.which('docker')
if not DOCKER_PATH:
    raise RuntimeError('docker is not installed')


def jwt_encode(payload: dict) -> str:
    return jwt_hs256.encode({'alg': 'HS256'}, payload, config.secret_key)


def jwt_decode(token: str) -> dict:
    data = jwt_hs256.decode(token, config.secret_key)
    data.validate()
    return data


def get_safe_env(*, add: dict[str, str] = {}) -> dict[str, str]:
    SAFE_KEYS = (
        'HOME',
        'INFOPATH',
        'LANG',
        'LIBEXEC_PATH',
        'LOCALE_ARCHIVE',
        'LOGNAME',
        'NIX_PATH',
        'NIX_PROFILES',
        'NIX_USER_PROFILE_DIR',
        'PATH',
        'SHELL',
        'TZDIR',
        'USER',
    )
    env = {}
    for k, v in os.environ.items():
        if k in SAFE_KEYS or k.startswith('XDG_'):
            env[k] = v
    env.update(add)
    return env
