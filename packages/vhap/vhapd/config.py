from pathlib import Path
from pydantic_settings import BaseSettings

from vhapd.schemas import AccessConfig


class Config(BaseSettings):
    host: str = '127.0.0.1'
    port: int = 8000
    debug: bool = False
    secret_key: str
    bot_token: str
    bot_username: str
    access_config_path: Path
    repo_dir: Path
    repo_containers_path: Path


config = Config(_env_file='.env')
if not config.repo_dir.is_dir():
    raise ValueError('repo_dir is not a directory')
if config.repo_containers_path.is_absolute():
    raise ValueError('repo_containers_path must be relative to repo_path')

access_config = AccessConfig.model_validate_json(config.access_config_path.read_text())

__all__ = ['config', 'access_config']
