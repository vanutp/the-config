from dataclasses import dataclass
import json
import logging
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory
import httpx

logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)

BASE_DIR = Path('/srv/vhap')
BASE_DIR.mkdir(parents=True, exist_ok=True)
CREDS_DIR = BASE_DIR / '_credentials'
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
    del app_config['metadata']


def add_composter_label_to_object(obj: dict):
    if obj.get('external', False):
        return
    add_label(obj, COMPOSTER_LABEL_KEY, 'true')


def add_composter_labels(app_config: dict):
    has_default_network = False
    for service in app_config.get('services', {}).values():
        curr_has_network_mode = 'network_mode' in service
        curr_has_default_network = 'default' in service.get('networks', ['default'])
        if curr_has_default_network and not curr_has_network_mode:
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
    traefik_cfg = service.pop('traefik', None)
    if traefik_cfg is None:
        return
    traefik_host = traefik_cfg.get('host')
    add_label(service, 'traefik.enable', 'true')
    if traefik_host:
        traefik_id = traefik_host.replace('.', '__')
        add_label(
            service,
            f'traefik.http.routers.{traefik_id}.rule',
            f'Host(`{traefik_host}`)',
        )
    if traefik_port := traefik_cfg.get('port'):
        if not traefik_host:
            print(
                '[vhap] ERROR: you must specify traefik.host when specifying traefik.port'
            )
            return
        add_label(
            service,
            f'traefik.http.services.{traefik_id}.loadbalancer.server.port',
            str(traefik_port),
        )


def apply_config(config_path: str):
    config = load_config(config_path)
    apps = config['apps']
    for name, app_config in apps.items():
        creds_data = {'creds_dir': str(CREDS_DIR), 'creds_required': app_config['auth']}
        cleanup_config(app_config)
        add_composter_labels(app_config)
        for service in app_config.get('services', {}).values():
            add_traefik_labels(service)
            if 'restart' not in service:
                service['restart'] = 'always'
        app_dir: Path = BASE_DIR / name
        should_update_dns = config['update-dns']['enable']  # and not app_dir.exists()
        app_dir.mkdir(exist_ok=True)
        if should_update_dns:
            (app_dir / '.vhap-update-dns').touch()
        (app_dir / 'docker-compose.yml').write_text(json.dumps(app_config))
        (app_dir / 'creds.vhap.json').write_text(json.dumps(creds_data))


def get_apps_on_disk():
    for path in BASE_DIR.glob('*'):
        if not path.is_dir():
            continue
        if not (path / 'docker-compose.yml').exists():
            continue
        yield path.name


@dataclass
class CFRecord:
    id: str
    name: str
    content: str
    proxied: bool


class DnsUpdater:
    zone_ids: dict[str, str]
    host_ip: str
    client: httpx.Client
    # Only A records for now
    _domain_cache: dict[str, list[CFRecord]] = {}

    def __init__(self, dns_cfg: dict):
        with open(dns_cfg['cloudflare-key-file'], 'r') as f:
            api_key = f.read()
        self.host_ip = dns_cfg['host-ip']
        self.client = httpx.Client(
            headers={'Authorization': f'Bearer {api_key}'},
            base_url='https://api.cloudflare.com/client/v4',
        )
        resp = self.client.get('/zones', params={'per_page': 1000})
        resp.raise_for_status()
        data = resp.json()
        if data['result_info']['total_count'] > data['result_info']['per_page']:
            raise ValueError('Too many zones')
        self.zone_ids = {
            zone['name']: zone['id']
            for zone in data['result']
        }

    def get_zone_records(self, zone_id: str) -> list[CFRecord] | None:
        if zone_id in self._domain_cache:
            return self._domain_cache[zone_id]
        resp = self.client.get(f'/zones/{zone_id}/dns_records', params={'per_page': 1000})
        resp.raise_for_status()
        data = resp.json()
        if data['result_info']['total_count'] > data['result_info']['per_page']:
            raise ValueError(f'Too many DNS records for zone {zone_id}')
        records = [
            CFRecord(
                id=record['id'],
                name=record['name'],
                content=record['content'],
                proxied=record['proxied'],
            )
            for record in data['result']
            if record['type'] == 'A'
        ]
        self._domain_cache[zone_id] = records
        return records

    def get_zone_id(self, domain: str) -> str | None:
        root_domain = '.'.join(domain.split('.')[-2:])
        zone_id = self.zone_ids.get(root_domain)
        if not zone_id:
            logger.info(f'Zone ID not set for root domain {domain}, skipping')
        return zone_id

    def update_domain_dns(self, domain: str, proxied: bool) -> None:
        if not (zone_id := self.get_zone_id(domain)):
            return
        if not (records := self.get_zone_records(zone_id)):
            return
        found_record = False
        to_remove = []
        for record in records:
            if record.name != domain:
                continue
            if record.content == self.host_ip and record.proxied == proxied:
                found_record = True
                continue
            resp = self.client.delete(f'/zones/{zone_id}/dns_records/{record.id}')
            resp.raise_for_status()
            logger.info(f'Removed DNS record {record}')
            to_remove.append(record)
        for record in to_remove:
            records.remove(record)
        if not found_record:
            resp = self.client.post(
                f'/zones/{zone_id}/dns_records',
                json={
                    'type': 'A',
                    'name': domain,
                    'content': self.host_ip,
                    'proxied': proxied,
                },
            )
            if resp.status_code != 200:
                logger.error(f'Failed to create DNS record for {domain}: {resp.json()}')
                resp.raise_for_status()
            record = CFRecord(
                id=resp.json()['result']['id'],
                name=domain,
                content=self.host_ip,
                proxied=proxied,
            )
            logger.info(f'Created DNS record {record}')
            records.append(record)

    def update_app_dns(self, app_cfg: dict) -> None:
        for service in app_cfg.get('services', {}).values():
            if not (traefik := service.get('traefik')):
                continue
            if not (host := traefik.get('host')):
                continue
            if traefik.get('update-dns', True):
                self.update_domain_dns(host, traefik.get('proxied', True))


def up_apps(config_path: str):
    config = load_config(config_path)
    ok = True
    update_dns_cfg = config['update-dns']
    if update_dns_cfg['enable']:
        dns_updater = DnsUpdater(update_dns_cfg)
    else:
        dns_updater = None
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
        app_dir = BASE_DIR / name
        update_dns_file = app_dir / '.vhap-update-dns'
        if update_dns_file.exists() and dns_updater:
            logger.info(f'Updating DNS for app {name}')
            update_dns_file.unlink()
            try:
                dns_updater.update_app_dns(app_cfg)
            except Exception:
                logger.exception(f'Failed to update DNS for app {name}')
                ok = False
        with TemporaryDirectory() as docker_cfg_dir:
            try:
                env = {
                    **os.environ,
                    'DOCKER_CONFIG': docker_cfg_dir,
                }
                for creds_id in app_cfg['auth']:
                    creds_file = CREDS_DIR / (creds_id + '.json')
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
                    cwd=app_dir,
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
