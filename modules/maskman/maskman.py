from dataclasses import dataclass
import fcntl
import json
import logging
import socket
import struct
import sys
import httpx

logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


def get_interface_ip(ifname: str) -> str:
    # https://stackoverflow.com/a/24196955
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(
        fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname.encode()[:15]),
        )[20:24]
    )


@dataclass
class CFRecord:
    id: str
    name: str
    content: str
    proxied: bool


@dataclass
class ConfigEntry:
    name: str
    target_interface: str | None
    proxied: bool


class DnsUpdater:
    zone_ids: dict[str, str]
    host_ip: str
    client: httpx.Client
    # Only A records for now
    _domain_cache: dict[str, list[CFRecord]] = {}

    def __init__(self, config: dict):
        with open(config['cloudflare-key-file'], 'r') as f:
            api_key = f.read()
        self.host_ip = config['host-ip']
        self.client = httpx.Client(
            headers={'Authorization': f'Bearer {api_key}'},
            base_url='https://api.cloudflare.com/client/v4',
        )
        resp = self.client.get('/zones', params={'per_page': 1000})
        resp.raise_for_status()
        data = resp.json()
        if data['result_info']['total_count'] > data['result_info']['per_page']:
            raise ValueError('Too many zones')
        self.zone_ids = {zone['name']: zone['id'] for zone in data['result']}

    def get_zone_records(self, zone_id: str) -> list[CFRecord] | None:
        if zone_id in self._domain_cache:
            return self._domain_cache[zone_id]
        resp = self.client.get(
            f'/zones/{zone_id}/dns_records', params={'per_page': 1000}
        )
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

    def update_entry(self, entry: ConfigEntry) -> None:
        if not (zone_id := self.get_zone_id(entry.name)):
            return
        if not (records := self.get_zone_records(zone_id)):
            return
        entry_content = self.host_ip
        if entry.target_interface:
            entry_content = get_interface_ip(entry.target_interface)
        found_record = False
        to_remove = []
        for record in records:
            if record.name != entry.name:
                continue
            if record.content == entry_content and record.proxied == entry.proxied:
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
                    'name': entry.name,
                    'content': entry_content,
                    'proxied': entry.proxied,
                },
            )
            if resp.status_code != 200:
                logger.error(
                    f'Failed to create DNS record for {entry.name}: {resp.json()}'
                )
                resp.raise_for_status()
            record = CFRecord(
                id=resp.json()['result']['id'],
                name=entry.name,
                content=entry_content,
                proxied=entry.proxied,
            )
            logger.info(f'Created DNS record {record}')
            records.append(record)


def main():
    if len(sys.argv) < 2:
        print('Usage: maskman.py <config_file>')
        sys.exit(1)
    with open(sys.argv[1]) as f:
        config = json.load(f)
    dns_updater = DnsUpdater(config)
    ok = True
    for entry in config['entries']:
        entry = ConfigEntry(
            name=entry['name'],
            target_interface=entry['target-interface'],
            proxied=entry['proxied'],
        )
        try:
            dns_updater.update_entry(entry)
        except Exception:
            logger.exception(f'Failed to update DNS for {entry.name}')
            ok = False
    if not ok:
        sys.exit(1)


if __name__ == '__main__':
    main()
