import asyncio
from contextlib import asynccontextmanager
import json
from pathlib import Path
import socket
from tempfile import TemporaryDirectory
from aiodocker import Docker
from vhapd.config import config
from vhapd.exceptions import _AppEvalError, DockerComposeError, LoginError
import vhapd.warnings
from vhapd.schemas import (
    App,
    AppMetadata,
    ContainerStatus,
    LiveContainer,
    PortBinding,
    RepoApp,
    VolumeBinding,
    VolumeBindingType,
)
from vhapd.utils import DOCKER_PATH, MANAGED_LABEL_KEY, NIX_PATH, VHAP_DIR, get_safe_env


class _UNSET:
    pass


async def get_containers(
    app_name: str | None | type[_UNSET] = _UNSET,
) -> list[LiveContainer]:
    docker = Docker()
    filters = {'all': 'true'}
    if app_name is None:
        raise NotImplementedError
    elif app_name is not _UNSET:
        filters = {'label': [f'com.docker.compose.project={app_name}']}
    res = await docker.containers.list(filters=filters)
    return [
        LiveContainer(
            name=container['Names'][0].removeprefix('/'),
            image=container['Image'],
            ports=[
                PortBinding(
                    host_ip=port['IP'],
                    host_port=port['PublicPort'],
                    container_port=port['PrivatePort'],
                    protocol=port['Type'],
                )
                for port in container['Ports']
                if port.get('PublicPort') is not None
            ],
            volumes=[
                VolumeBinding(
                    type=VolumeBindingType(volume['Type']),
                    name=volume.get('Name'),
                    driver=volume.get('Driver'),
                    source=volume['Source'],
                    destination=volume['Destination'],
                    mode=volume['Mode'],
                    read_write=volume['RW'],
                    propagation=volume['Propagation'],
                )
                for volume in container['Mounts']
            ],
            labels=container['Labels'],
            status=ContainerStatus(container['State']),
        )
        for container in res
    ]


async def eval_nix_app_config(contents: str) -> dict | None:
    with TemporaryDirectory() as tmp_dir:
        file = Path(tmp_dir) / 'default.nix'
        file.write_text(contents)
        flake = Path(tmp_dir) / 'flake.nix'
        flake.write_text('{outputs = {...}: { default = import ./default.nix {}; };}')
        p = await asyncio.create_subprocess_exec(
            NIX_PATH,
            'eval',
            '--json',
            '.#default',
            stdin=asyncio.subprocess.DEVNULL,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=tmp_dir,
        )
        stdout, stderr = await p.communicate()
    if p.returncode != 0:
        raise _AppEvalError(stdout.decode(), stderr.decode())
    return json.loads(stdout)


_get_repo_app_names_cached_result: list[str] | None = None


async def get_repo_app_names() -> list[str]:
    global _get_repo_app_names_cached_result
    if _get_repo_app_names_cached_result:
        return _get_repo_app_names_cached_result
    hostname = socket.gethostname()
    p = await asyncio.create_subprocess_exec(
        NIX_PATH,
        'eval',
        '--json',
        f'.#nixosConfigurations.{hostname}.config.virtualisation.composter.apps',
        '--apply',
        'builtins.attrNames',
        stdin=asyncio.subprocess.DEVNULL,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await p.communicate()
    if p.returncode != 0:
        raise RuntimeError('Failed to get app names', stderr.decode())
    _get_repo_app_names_cached_result = json.loads(stdout)
    return _get_repo_app_names_cached_result


async def get_repo_app(app_name: str) -> RepoApp | None:
    # TODO: update repository && cache results
    containers_dir = config.repo_dir / config.repo_containers_path
    app_config_file = containers_dir / f'{app_name}.nix'
    if not app_config_file.is_file():
        if app_name in await get_repo_app_names():
            return RepoApp(
                name=app_name,
                metadata=None,
                nix_config=None,
                json_data=None,
                warnings=[],
            )
        else:
            return None
    nix_config = app_config_file.read_text()
    try:
        json_data = await eval_nix_app_config(nix_config)
    except _AppEvalError:
        json_data = None
    if json_data:
        app_config = (
            json_data.get('virtualisation', {})
            .get('composter', {})
            .get('apps', {})
            .get(app_name, {})
        )
        metadata = AppMetadata.model_validate(app_config.get('metadata', {}))
    else:
        metadata = None
    return RepoApp(
        name=app_name,
        metadata=metadata,
        nix_config=nix_config,
        json_data=json_data,
        warnings=[],
    )


async def get_repo_apps() -> list[RepoApp]:
    apps: list[RepoApp] = []
    for app_name in await get_repo_app_names():
        apps.append(await get_repo_app(app_name))
    return apps


def _get_empty_app(app_name: str) -> App:
    return App(
        name=app_name,
        metadata=AppMetadata(owners=[]),
        nix_config=None,
        json_data=None,
        managed=False,
        live_containers=[],
        warnings=[],
    )


async def get_full_app(app_name: str) -> App | None:
    # !!! should be kept in sync with get_full_apps !!!
    containers = await get_containers(app_name)
    app: App = _get_empty_app(app_name)
    for i, container in enumerate(containers):
        managed = container.labels.get(MANAGED_LABEL_KEY) == 'true'
        if i == 0:
            app.managed = managed
        app.live_containers.append(container)
        if managed != app.managed:
            app.managed = True
            app.warnings.append(vhapd.warnings.APP_NOT_FULLY_MANAGED)

    # at this point app.managed is True if any container has the label

    repo_app = await get_repo_app(app_name)
    if repo_app:
        if len(app.live_containers) == 0:
            app.managed = True
        app.metadata = repo_app.metadata
        app.nix_config = repo_app.nix_config
        app.json_data = repo_app.json_data
        app.warnings.extend(repo_app.warnings)
        if not app.managed:
            app.warnings.append(vhapd.warnings.APP_CONFIGURED_BUT_RUNNING_UNMANAGED)
    else:
        if len(app.live_containers) == 0:
            return None
        if app.managed:
            app.warnings.append(vhapd.warnings.APP_ORPHANED)
            app.managed = False

    return app


async def get_full_apps() -> list[App]:
    # !!! should be kept in sync with get_full_app !!!
    containers = await get_containers()
    apps: dict[str, App] = {}
    for container in containers:
        app_name = container.labels.get('com.docker.compose.project')
        if not app_name:
            continue
        managed = container.labels.get(MANAGED_LABEL_KEY) == 'true'
        if app_name not in apps:
            apps[app_name] = _get_empty_app(app_name)
            apps[app_name].managed = managed
        apps[app_name].live_containers.append(container)
        if managed != apps[app_name].managed:
            apps[app_name].managed = True
            apps[app_name].warnings.append(vhapd.warnings.APP_NOT_FULLY_MANAGED)

    # at this point app.managed is True if any container has the label

    repo_apps = await get_repo_apps()
    repo_app_names = {app.name for app in repo_apps}
    running_app_names = set(apps.keys())
    for app_name in running_app_names - repo_app_names:
        if apps[app_name].managed:
            apps[app_name].warnings.append(vhapd.warnings.APP_ORPHANED)
            apps[app_name].managed = False

    for repo_app in repo_apps:
        if repo_app.name not in apps:
            apps[repo_app.name] = _get_empty_app(repo_app.name)
            apps[repo_app.name].managed = True
        final_app = apps[repo_app.name]
        final_app.metadata = repo_app.metadata
        final_app.nix_config = repo_app.nix_config
        final_app.json_data = repo_app.json_data
        final_app.warnings.extend(repo_app.warnings)
        if not final_app.managed:
            final_app.warnings.append(
                vhapd.warnings.APP_CONFIGURED_BUT_RUNNING_UNMANAGED
            )

    return list(apps.values())


async def run_docker_compose(
    app_name: str,
    args: list[str],
    *,
    env: dict[str, str] = {},
) -> tuple[str, str]:
    p = await asyncio.create_subprocess_exec(
        DOCKER_PATH,
        'compose',
        *args,
        cwd=VHAP_DIR / app_name,
        env=get_safe_env(add=env),
        stdin=asyncio.subprocess.DEVNULL,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await p.communicate()
    if p.returncode != 0:
        raise DockerComposeError(' '.join(args), stdout, stderr)
    return stdout, stderr


# TODO: just write docker config without running login
@asynccontextmanager
async def with_creds(app_name: str):
    with TemporaryDirectory() as docker_cfg_dir:
        app_dir = VHAP_DIR / app_name
        env = {'DOCKER_CONFIG': docker_cfg_dir}
        if (vhap_creds_file := (app_dir / 'creds.vhap.json')).exists():
            vhap_creds = json.loads(vhap_creds_file.read_text())
            creds_dir = Path(vhap_creds['creds_dir'])
            for creds_id in vhap_creds['creds_required']:
                creds_file = creds_dir / (creds_id + '.json')
                creds = json.loads(creds_file.read_text())
                args = [
                    'login',
                    '--username',
                    creds['username'],
                    '--password-stdin',
                    creds['server'],
                ]
                p = await asyncio.create_subprocess_exec(
                    DOCKER_PATH,
                    *args,
                    cwd=app_dir,
                    env=get_safe_env(add=env),
                    stdin=asyncio.subprocess.PIPE,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                stdout, stderr = await p.communicate(creds['password'].encode())
                if p.returncode != 0:
                    raise LoginError(' '.join(args), stdout, stderr)
        yield env


async def app_down(app_name: str) -> None:
    # TODO: check if app is really at /srv/vhap/{app_name}
    # TODO: check if app's docker-compose.yml is linked
    await run_docker_compose(app_name, ['down', '--remove-orphans'])


async def app_up(app_name: str) -> None:
    async with with_creds(app_name) as env:
        await run_docker_compose(app_name, ['docker', 'compose', 'up', '-d'], env=env)


async def app_stop(app_name: str) -> None:
    await run_docker_compose(app_name, ['docker', 'compose', 'stop'])


async def app_start(app_name: str) -> None:
    await run_docker_compose(app_name, ['docker', 'compose', 'start'])
