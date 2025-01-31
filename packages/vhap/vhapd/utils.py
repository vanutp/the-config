import os
from pathlib import Path
import shutil
from typing import Any
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

NOTSET = object()


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

def obj_diff(a: list | dict, b: list | dict, path: list[str] | None = None) -> list[str]:
    """Returns list of differences"""
    if path is None:
        path = []
    errors = []
    if isinstance(a, dict) and isinstance(b, dict):
        for k, v in a.items():
            if k not in b:
                errors.append('.'.join(path + [k]))
            else:
                errors.extend(obj_diff(v, b[k], path + [k]))
        for k in b.keys() - a.keys():
            errors.append('.'.join(path + [k]))
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            errors.append('.'.join(path))
        else:
            for i, (x, y) in enumerate(zip(a, b)):
                errors.extend(obj_diff(x, y, path + [str(i)]))
    elif a != b:
        errors.append('.'.join(path))

def validate_nix_service(prev: dict, new: dict) -> list[str]:
    allowed_service_keys = {
        'depends_on',
        'deploy.resources.limits',
        'entrypoint',
        'env_file',
        'environment',
        'expose',
        'extra_hosts',
        'healthcheck',
        'hostname',
        'image',
        'pull_policy',
        'ports',
        'restart',
        'stdin_open',
        'stop_grace_period',
        'tty',
        'ulimits',
        'user',
        'volumes',
        'working_dir',
    }


def validate_nix_app(prev: dict, new: dict) -> list[str]:
    ...
    

def validate_nix_config(prev: dict, new: dict) -> list[str]:
    """Returns list of errors"""