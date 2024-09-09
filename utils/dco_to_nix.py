from io import BytesIO
import json
import logging
from pathlib import Path
import re
import subprocess
import sys
from tempfile import NamedTemporaryFile
from textwrap import dedent
import yaml


logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


def convert_app(app: dict):
    app.pop('version', None)
    for service in app.get('services', {}).values():
        for opt in ('labels', 'environment'):
            if isinstance(opt_val := service.get(opt, {}), list):
                new_opt_val = {}
                for entry in opt_val:
                    k, v = entry.split('=', 1)
                    new_opt_val[k] = v
                service[opt] = new_opt_val
        if service.get('restart') == 'always':
            del service['restart']
        new_labels = {}
        for k, v in service.get('labels', {}).items():
            if (k, v) == ('traefik.enable', 'true'):
                service['traefik'] = {}
            elif re.fullmatch(r'traefik.http.routers.([^.]+).rule', k) and (
                host_match := re.fullmatch(r'Host\(`([^`]+)`\)', v)
            ):
                service['traefik']['host'] = host_match.group(1)
            elif re.fullmatch(
                r'traefik.http.services.([^.]+).loadbalancer.server.port', k
            ):
                service['traefik']['port'] = int(v)
            else:
                new_labels[k] = v
        if 'labels' in service:
            if new_labels:
                service['labels'] = new_labels
            else:
                del service['labels']


def json_to_nix(app: dict) -> str:
    with NamedTemporaryFile('w') as f:
        json.dump(app, f, indent=2)
        f.flush()
        return subprocess.check_output(
            [
                'nix-instantiate',
                '--eval',
                '-E',
                f'builtins.fromJSON (builtins.readFile {f.name})',
            ],
            input=json.dumps(app).encode(),
        ).decode()


def main():
    if len(sys.argv) != 3:
        logger.error('Invalid number of arguments')
        return
    containers_dir = Path(sys.argv[1]).absolute()
    out_dir = Path(sys.argv[2]).absolute()
    default_nix = '{...}: {imports = ['
    for app_dir in sorted(containers_dir.glob('*')):
        if not app_dir.is_dir():
            continue
        dco_yaml = app_dir / 'docker-compose.yml'
        if not dco_yaml.exists():
            continue
        data = yaml.safe_load(dco_yaml.read_text())
        convert_app(data)
        app_name = app_dir.name.replace('.', '_')
        nix_file_contents = dedent(
            f"""
            {{...}}: {{
                virtualisation.composter.apps.{app_name} = {json_to_nix(data)};
            }}
        """.strip()
        )
        nix_file = out_dir / (app_name + '.nix')
        nix_file.write_text(nix_file_contents)
        default_nix += f'./{nix_file.name}\n'
    default_nix += '];}'
    (out_dir / 'default.nix').write_text(default_nix)


if __name__ == '__main__':
    main()
