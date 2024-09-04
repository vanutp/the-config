import json
import logging
from pathlib import Path
import subprocess
import sys

logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)

APPS_BASE_DIR = Path('/srv/composter')
APPS_BASE_DIR.mkdir(parents=True, exist_ok=True)
COMPOSTER_LABEL_KEY = 'dev.vanutp.composter.managed'


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
    with open(config_path) as f:
        config = json.load(f)
    apps = config['apps']
    for name, app_config in apps.items():
        cleanup_config(app_config)
        add_composter_labels(app_config)
        for service in app_config.get('services', {}).values():
            add_traefik_labels(service)
            if 'restart' not in service:
                service['restart'] = 'on-failure:3'
        app_dir: Path = APPS_BASE_DIR / name
        app_dir.mkdir(exist_ok=True)
        (app_dir / 'docker-compose.yml').write_text(json.dumps(app_config))


def get_apps_on_disk():
    for path in APPS_BASE_DIR.glob('*'):
        if not path.is_dir():
            continue
        if not (path / 'docker-compose.yml').exists():
            continue
        yield path.name


def up_apps(config_path: str):
    ok = True
    with open(config_path) as f:
        config = json.load(f)
    apps = config['apps']
    apps_to_remove = set(get_apps_on_disk()) - set(apps.keys())
    for name in apps_to_remove:
        app_dir = APPS_BASE_DIR / name
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
    for name in apps:
        logger.info(f'Starting app {name}')
        try:
            subprocess.check_call(
                [
                    'docker',
                    'compose',
                    'up',
                    '-d',
                    '--remove-orphans',
                ],
                cwd=APPS_BASE_DIR / name,
            )
        except subprocess.CalledProcessError:
            logger.error(f'Failed to start app {name}')
            ok = False
        else:
            logger.info(f'Started app {name}')
    return ok


def main():
    if len(sys.argv) < 2:
        print('No command specified')
        return
    if sys.argv[1] == 'apply_config':
        if len(sys.argv) == 3:
            apply_config(sys.argv[2])
        else:
            print('Invalid number of arguments')
    elif sys.argv[1] == 'up':
        if len(sys.argv) == 3:
            if not up_apps(sys.argv[2]):
                sys.exit(1)
        else:
            print('Invalid number of arguments')
    else:
        print('Invalid command')


if __name__ == '__main__':
    main()
