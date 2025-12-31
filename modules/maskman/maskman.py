from dataclasses import dataclass
import fcntl
from ipaddress import IPv6Address, IPv6Network
import json
import logging
import socket
import struct
import sys
from typing import Literal
import httpx

logging.basicConfig(
    format='%(asctime)s %(levelname)s: %(message)s',
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


def get_ipv4_address(ifname: str) -> str:
    # https://stackoverflow.com/a/24196955
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(
        fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname.encode()[:15]),
        )[20:24]
    )


def get_ipv6_address(ifname) -> str | None:
    # https://github.com/giampaolo/psutil/blob/dd49bbe2271c4acbf24b75c89d1cae914744d6bf/tests/test_linux.py#L102
    raw_addresses = []
    with open('/proc/net/if_inet6') as f:
        for line in f:
            fields = line.split()
            if fields[-1] == ifname:
                raw_addresses.append(fields[0])
    if len(raw_addresses) == 0:
        raise ValueError(f'Could not find interface {ifname!r}')

    res = []
    ll_subnet = IPv6Network('fe80::/10')
    for unformatted in raw_addresses:
        groups = [unformatted[j : j + 4] for j in range(0, len(unformatted), 4)]
        addr = IPv6Address(':'.join(groups))
        if addr not in ll_subnet:
            res.append(str(addr))
    if len(res) == 0:
        return None
    elif len(res) == 1:
        return res[0]
    else:
        raise ValueError(f'Multiple IPv6 addresses found for interface {ifname!r}')


@dataclass
class CFRecord:
    id: str
    name: str
    type: Literal['A', 'AAAA']
    content: str
    proxied: bool


@dataclass
class ConfigEntry:
    name: str
    target_interface: str | None
    proxied: bool


class DnsUpdater:
    zone_ids: dict[str, str]
    host_ipv4: str
    host_ipv6: str | None
    client: httpx.Client
    # Only A records for now
    _domain_cache: dict[str, list[CFRecord]] = {}

    def __init__(self, config: dict):
        with open(config['cloudflare-key-file'], 'r') as f:
            api_key = f.read()
        self.host_ipv4 = config['host-ipv4']
        self.host_ipv6 = config['host-ipv6']
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
                type=record['type'],
                content=record['content'],
                proxied=record['proxied'],
            )
            for record in data['result']
            if record['type'] == 'A'
            or record['type'] == 'CNAME'
            or record['type'] == 'AAAA'
        ]
        self._domain_cache[zone_id] = records
        return records

    def get_zone_id(self, domain: str) -> str | None:
        root_domain = '.'.join(domain.split('.')[-2:])
        zone_id = self.zone_ids.get(root_domain)
        if not zone_id:
            logger.info(f'Zone ID not set for root domain {domain}, skipping')
        return zone_id

    def create_record(
        self,
        zone_id: str,
        name: str,
        type_: Literal['A', 'AAAA'],
        content: str,
        proxied: bool,
    ) -> CFRecord:
        resp = self.client.post(
            f'/zones/{zone_id}/dns_records',
            json={
                'type': type_,
                'name': name,
                'content': content,
                'proxied': proxied,
            },
        )
        if resp.status_code != 200:
            logger.error(f'Failed to create DNS record for {name}: {resp.json()}')
            resp.raise_for_status()
        record = CFRecord(
            id=resp.json()['result']['id'],
            name=name,
            type=type_,
            content=content,
            proxied=proxied,
        )
        logger.info(f'Created DNS record {record}')
        return record

    def update_entry(self, entry: ConfigEntry) -> None:
        if not (zone_id := self.get_zone_id(entry.name)):
            return
        if not (records := self.get_zone_records(zone_id)):
            return
        entry_content_v4 = self.host_ipv4
        entry_content_v6 = self.host_ipv6
        if entry.target_interface:
            entry_content_v4 = get_ipv4_address(entry.target_interface)
            entry_content_v6 = get_ipv6_address(entry.target_interface)
        found_record_v4 = False
        found_record_v6 = False
        to_remove = []
        for record in records:
            if record.name != entry.name:
                continue
            if record.content == entry_content_v4 and record.proxied == entry.proxied:
                found_record_v4 = True
                continue
            if record.content == entry_content_v6 and record.proxied == entry.proxied:
                found_record_v6 = True
                continue
            resp = self.client.delete(f'/zones/{zone_id}/dns_records/{record.id}')
            resp.raise_for_status()
            logger.info(f'Removed DNS record {record}')
            to_remove.append(record)
        for record in to_remove:
            records.remove(record)
        if not found_record_v4:
            records.append(
                self.create_record(
                    zone_id, entry.name, 'A', entry_content_v4, entry.proxied
                )
            )
        if not found_record_v6:
            records.append(
                self.create_record(
                    zone_id, entry.name, 'AAAA', entry_content_v6, entry.proxied
                )
            )


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
