# Networking

## Physical path

ISP modem → `prodesk-worker` NIC 1 → OPNsense WAN `vtnet0`. OPNsense LAN `vtnet1` → VLAN-aware Proxmox bridge → `prodesk-worker` NIC 2 → TL-SG108E port 2 (trunk) → access ports.


## Addressing plan

| Network | VLAN | Subnet | Gateway | DHCP | Doc |
|---|---|---|---|---|---|
| LAN | 1 (untagged) | `<lan-subnet>` | `<opnsense-ip>` | `<lan-dhcp-range>` (Dnsmasq) | this page |
| Isolated_WiFi | 20 | `<vlan20-subnet>` | `<vlan20-gateway>` | `<vlan20-dhcp-range>` | [VLAN 20](vlans/vlan20-isolated-wifi.md) |

Convention: each VLAN gets its own `/24`, with the gateway at `.1` and DHCP on `.100`-`.200`.

### Static / reserved addresses

Real addresses are kept out of this repo. The IP column gives each host's placeholder (e.g. `<plex-ip>`), which other docs use in its place.

| Host | Hostname | IP | Notes |
|---|---|---|---|
| OPNsense | `opnsense.hydralab.lan` (via Caddy) | `<opnsense-ip>` | LAN gateway. GUI also at `http://<opnsense-ip>` |
| `HydraServerMox` | | `<hydraserver-ip>` | Proxmox node |
| `nuc-worker` | | `<nuc-ip>` | Proxmox node |
| `prodesk-worker` | | `<prodesk-ip>` | Proxmox node |
| `elitedesk-worker` | | `<elitedesk-ip>` | Proxmox node |
| Unraid media VM | | `<unraid-ip>` | Also Prowlarr, Sonarr, Radarr, qBittorrent |
| Plex VM | | `<plex-ip>` | Only internal host reachable from VLAN 20. No hostname; reached by IP |
| Wazuh | `wazuh.hydralab.lan` (web, via Caddy) | `<wazuh-ip>` | Static mapping in Dnsmasq. Agents use the IP |
| Homepage | `homepage.hydralab.lan` (via Caddy) | `<homepage-ip>` | Port `3000`; LXC `113` on `elitedesk-worker`. Static mapping in Dnsmasq. [Doc](../dashboard/homepage.md) |
| Grafana | `grafana.hydralab.lan` (via Caddy) | `<grafana-ip>` | Port `3000`; LXC `123` on `elitedesk-worker`. `domain`/`root_url` in `grafana.ini` set to the Caddy name. Static mapping in Dnsmasq |
| InfluxDB | `influxdb.hydralab.lan` (via Caddy) | `<influxdb-ip>` | Port `8086`; LXC `124` on `elitedesk-worker`. Static mapping in Dnsmasq |
| Splunk | `splunk.hydralab.lan` (via Caddy) | `<splunk-ip>` | Port `8000`; LXC `126` on `elitedesk-worker`. Static mapping in Dnsmasq |
| Wiki.js | `wiki.hydralab.lan` (via Caddy) | `<wiki-ip>` | Port `3000`; LXC `119` on `elitedesk-worker` |
| Vaultwarden | `vaultwarden.hydralab.lan` (via Caddy) | `<vaultwarden-ip>` | Port `8000` (self-signed HTTPS); LXC `110` on `elitedesk-worker`. Static mapping in Dnsmasq. [Doc](../security/vaultwarden.md) |
| Immich | `immich.hydralab.lan` (via Caddy) | `<immich-ip>` | Static, port `2283`; LXC `127` on `HydraServerMox`. [Doc](../media/immich.md) |
| Caddy | `caddy` | `<caddy-ip>` | Reverse proxy for every `*.hydralab.lan` name; LXC `102` on `prodesk-worker`. [Doc](reverse-proxy.md) |
| `WIN-DC01` | | `<dc01-ip>` | Domain controller |
| `WIN-DC02` | | `<dc02-ip>` | Domain controller |
| Main PC | | `<main-pc-ip>` | Switch port 6 |
| Tenda AP | | `<tenda-ap-ip>` | Main WiFi AP (LAN) |
| Guest Wi-Fi AP | | `<orbi-ip>` | Guest AP (VLAN 20) |
| TL-SG108E switch | | TODO: | |

## OPNsense

| Item | Value |
|---|---|
| Deployment | VM on `prodesk-worker` |
| WAN | `vtnet0`, ISP |
| LAN | `vtnet1`, `<opnsense-ip>/24` |
| DHCP | Dnsmasq DNS & DHCP (DNS listener moved to `53053`) |
| DNS | Unbound on `53`. See [DNS](../dns/README.md) |
| Internal CA | `HydraLab Root CA` (System → Trust), issues the `*.hydralab.lan` cert. See [Reverse proxy](reverse-proxy.md#certificates) |
| VLAN Hardware Filtering | Disabled (virtio) |

### Aliases

| Name | Type | Content | Used by |
|---|---|---|---|
| `RFC1918` | Network(s) | all three RFC 1918 private ranges | Isolation block rules |
| `Plex` | Port(s) | `32400` | VLAN 20 Plex rule |

### Firewall philosophy

- New segments are **deny-by-default** toward internal networks: pass DNS to the gateway, pass specific services, block `RFC1918` (logged), then pass to any.
- Rules point at **service IPs** (the LXC), never at a Proxmox node, so management UIs stay unreachable.
- Every rule gets a description.

## Switch: TP-Link TL-SG108E v6

| Port | Connected to | VLAN 1 | VLAN 20 | PVID |
|---|---|---|---|---|
| 1 | Not documented here | | | |
| 2 | `prodesk-worker` NIC 2: OPNsense trunk | Untagged | Tagged (TODO: confirm) | 1 |
| 3 | `HydraServerMox` | Untagged | | 1 |
| 4 | `nuc-worker` | Untagged | | 1 |
| 5 | Guest Wi-Fi AP | | Untagged | 20 |
| 6 | Main PC (`<main-pc-ip>`) | Untagged | | 1 |
| 7 | `elitedesk-worker` | Untagged | | 1 |
| 8 | Empty | Untagged | | 1 |

Switch gotchas are in the [VLAN 20 doc](vlans/vlan20-isolated-wifi.md#1-tp-link-tl-sg108e-switch). Short version: 802.1Q mode only, set PVID before removing a port from VLAN 1, never touch the trunk port's VLAN 1 settings, and **Save Config**.

## Wireless

| Network | AP | Segment |
|---|---|---|
| Guest Wi-Fi | Standalone consumer satellite | VLAN 20 |
| Main Wi-Fi | Tenda AP (`<tenda-ap-ip>`) | LAN |
