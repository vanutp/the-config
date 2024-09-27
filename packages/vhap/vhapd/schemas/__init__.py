from enum import StrEnum
from pydantic import BaseModel


class AppMetadata(BaseModel):
    owners: list[int] = []


class ContainerStatus(StrEnum):
    created = 'created'
    running = 'running'
    paused = 'paused'
    restarting = 'restarting'
    removing = 'removing'
    exited = 'exited'
    dead = 'dead'


class PortBinding(BaseModel):
    host_ip: str
    host_port: int
    container_port: int
    protocol: str

class VolumeBindingType(StrEnum):
    bind = 'bind'
    volume = 'volume'
    tmpfs = 'tmpfs'
    npipe = 'npipe'
    cluster = 'cluster'

class VolumeBinding(BaseModel):
    type: VolumeBindingType
    name: str | None
    driver: str | None
    source: str
    destination: str
    mode: str
    read_write: bool
    propagation: str


class LiveContainer(BaseModel):
    name: str
    image: str
    ports: list[PortBinding]
    volumes: list[VolumeBinding]
    labels: dict[str, str]
    status: ContainerStatus

class RepoApp(BaseModel):
    name: str
    metadata: AppMetadata | None
    nix_config: str | None
    # data from evaluated .nix file (if possible)
    json_data: dict | None
    warnings: list[str]

class App(RepoApp):
    # is in nix config somewhere
    managed: bool
    live_containers: list[LiveContainer]


class AccessConfigEntry(BaseModel):
    id: int
    is_admin: bool


class AccessConfig(BaseModel):
    users: list[AccessConfigEntry]


class TelegramUser(BaseModel):
    id: int
    first_name: str
    last_name: str | None = None
    username: str | None = None
    photo_url: str | None = None
    auth_date: int


class User(AccessConfigEntry, TelegramUser):
    pass
