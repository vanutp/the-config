import json
import logging
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)

BASE_DIR = Path('/srv/vhap')
BASE_DIR.mkdir(parents=True, exist_ok=True)
COMPOSTER_LABEL_KEY = 'dev.vanutp.composter.managed'


def load_config(config_path: str) -> dict:
    with open(config_path) as f:
        return json.load(f)


def add_label(obj: dict, key: str, value: str):
    obj['labels'] = obj.get('labels', [])
    if isinstance(obj['labels'], list):
        obj['labels'].append(f'{key}={value}')
    else:
        obj['labels'][key] = value


def cleanup_config(app_config: dict):
    for key in ('services', 'networks', 'volumes'):
        if app_config.get(key) is None:
            del app_config[key]
    del app_config['appDir']
    del app_config['auth']


def add_composter_label_to_object(obj: dict):
    if obj.get('external', False):
        return
    add_label(obj, COMPOSTER_LABEL_KEY, 'true')


def add_composter_labels(app_config: dict):
    has_default_network = False
    for service in app_config.get('services', {}).values():
        curr_has_network_mode = 'network_mode' in service
        curr_has_default_network = 'default' in service.get('networks', ['default'])
        if not curr_has_default_network and curr_has_network_mode:
            has_default_network = True
        add_composter_label_to_object(service)
    if (
        'networks' not in app_config or len(app_config['networks']) == 0
    ) and has_default_network:
        app_config['networks'] = {'default': {}}
    for network in app_config.get('networks', {}).values():
        add_composter_label_to_object(network)
    for volume in app_config.get('volumes', {}).values():
        add_composter_label_to_object(volume)


def add_traefik_labels(service: dict):
    # TODO: throw an error if traefik is not enabled in system
    # but .traefik is set on a service
    traefik_cfg = service.pop('traefik', {})
    if not traefik_cfg:
        return
    traefik_host = traefik_cfg['host']
    traefik_port = traefik_cfg.get('port')
    traefik_id = traefik_host.replace('.', '__')
    add_label(service, 'traefik.enable', 'true')
    add_label(
        service,
        f'traefik.http.routers.{traefik_id}.rule',
        f'Host(`{traefik_host}`)',
    )
    if traefik_port:
        add_label(
            service,
            f'traefik.http.services.{traefik_id}.loadbalancer.server.port',
            str(traefik_port),
        )


def apply_config(config_path: str):
    config = load_config(config_path)
    apps = config['apps']
    for name, app_config in apps.items():
        cleanup_config(app_config)
        add_composter_labels(app_config)
        for service in app_config.get('services', {}).values():
            add_traefik_labels(service)
            if 'restart' not in service:
                service['restart'] = 'on-failure:3'
        app_dir: Path = BASE_DIR / name
        app_dir.mkdir(exist_ok=True)
        (app_dir / 'docker-compose.yml').write_text(json.dumps(app_config))


def get_apps_on_disk():
    for path in BASE_DIR.glob('*'):
        if not path.is_dir():
            continue
        if not (path / 'docker-compose.yml').exists():
            continue
        yield path.name


def up_apps(config_path: str):
    config = load_config(config_path)
    ok = True
    apps = config['apps']
    apps_to_remove = set(get_apps_on_disk()) - set(apps.keys())
    for name in apps_to_remove:
        app_dir = BASE_DIR / name
        logger.info(f'Removing app {name}')
        try:
            subprocess.check_call(
                ['docker', 'compose', 'down', '--remove-orphans'],
                cwd=app_dir,
            )
        except subprocess.CalledProcessError:
            logger.error(f'Failed to remove app {name}')
            ok = False
        else:
            logger.info(f'Removed app {name}')
        (app_dir / 'docker-compose.yml').unlink()
        if len(list(app_dir.glob('*'))) == 0:
            app_dir.rmdir()
    for name, app_cfg in apps.items():
        logger.info(f'Starting app {name}')
        with TemporaryDirectory() as docker_cfg_dir:
            try:
                env = {
                    **os.environ,
                    'DOCKER_CONFIG': docker_cfg_dir,
                }
                for creds_id in app_cfg['auth']:
                    creds_file = BASE_DIR / '_credentials' / (creds_id + '.json')
                    creds = json.loads(creds_file.read_text())
                    subprocess.check_output(
                        [
                            'docker',
                            'login',
                            '--username',
                            creds['username'],
                            '--password-stdin',
                            creds['server'],
                        ],
                        env=env,
                        input=creds['password'].encode(),
                    )
                subprocess.check_call(
                    [
                        'docker',
                        'compose',
                        'up',
                        '-d',
                        '--quiet-pull',
                        '--remove-orphans',
                    ],
                    cwd=BASE_DIR / name,
                    env=env,
                )
            except subprocess.CalledProcessError:
                logger.error(f'Failed to start app {name}')
                ok = False
            else:
                logger.info(f'Started app {name}')
    return ok


def down_apps(config_path: str):
    config = load_config(config_path)
    ok = True
    apps = config['apps']
    for name in apps:
        logger.info(f'Stopping app {name}')
        try:
            subprocess.check_call(
                ['docker', 'compose', 'down', '--remove-orphans'],
                cwd=BASE_DIR / name,
            )
        except subprocess.CalledProcessError:
            logger.error(f'Failed to stop app {name}')
            ok = False
        else:
            logger.info(f'Stopped app {name}')
    return ok


def main():
    if len(sys.argv) < 2:
        print('No command specified')
        sys.exit(1)
    if len(sys.argv) != 3:
        print('Invalid number of arguments')
        sys.exit(1)
    if sys.argv[1] == 'apply_config':
        apply_config(sys.argv[2])
    elif sys.argv[1] == 'down':
        if not down_apps(sys.argv[2]):
            sys.exit(1)
    elif sys.argv[1] == 'up':
        if not up_apps(sys.argv[2]):
            sys.exit(1)
    else:
        print('Invalid command')


if __name__ == '__main__':
    main()
