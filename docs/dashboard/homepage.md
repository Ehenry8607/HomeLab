# Homepage dashboard

[Homepage](https://gethomepage.dev) is the lab's service dashboard. Other docs refer to hosts by name and link here for addresses.

The `services.yaml` block below matches the live config (applied 2026-11-27). Services behind the [Caddy reverse proxy](../networking/reverse-proxy.md) link by `*.hydralab.lan` name.

The full host list, including APs, is in [Networking](../networking/README.md#static--reserved-addresses).

Subnets and the VLAN convention (one `/24` per VLAN, gateway `.1`, DHCP `.100`-`.200`) are documented in [Networking](../networking/README.md#addressing-plan).

| | |
|---|---|
| **Runs on** | LXC `113` on `elitedesk-worker`, Debian 13, `homepage.service` (`pnpm start` in `/opt/homepage`). `HOMEPAGE_ALLOWED_HOSTS` is set in the `override.conf` drop-in |
| **URL** | `https://homepage.hydralab.lan` (via [Caddy](../networking/reverse-proxy.md#proxied-services)) |
| **Config path** | `/opt/homepage/config/` (`services.yaml`, `bookmarks.yaml`, …). The page is served pre-built; after editing, rebuild it with `curl -s https://homepage.hydralab.lan/api/revalidate` |

## services.yaml

```yaml
---
- Network:
    - OPNsense:
        href: https://opnsense.hydralab.lan
        description: Firewall & Router
        icon: opnsense.png
    - Plex:
        href: http://<plex-ip>:32400
        description: Media Server
        icon: plex.png

- Monitoring:
    - Wazuh:
        href: https://wazuh.hydralab.lan
        description: SIEM
        icon: wazuh.png
    - Grafana:
        href: https://grafana.hydralab.lan
        description: Metrics dashboards
        icon: grafana.png
    - Splunk:
        href: https://splunk.hydralab.lan
        description: Log search & SIEM
        icon: splunk.png

- Proxmox:
    - HydraServerMox:
        href: https://hydraserver.hydralab.lan
        description: Proxmox Node
        icon: proxmox.png
    - nuc-worker:
        href: https://nuc.hydralab.lan
        description: Proxmox Node
        icon: proxmox.png
    - prodesk-worker:
        href: https://prodesk.hydralab.lan
        description: Proxmox Node
        icon: proxmox.png
    - elitedesk-worker:
        href: https://elitedesk.hydralab.lan
        description: Proxmox Node
        icon: proxmox.png
- Media:
    - Radarr:
        icon: radarr.png
        href: http://<unraid-ip>:7878
        description: Movies
    - Sonarr:
        icon: sonarr.png
        href: http://<unraid-ip>:8989
        description: TV
    - qBittorrent:
        icon: qbittorrent.png
        href: http://<unraid-ip>:8080
        description: Downloads (PIA)
    - Immich:
        icon: immich.png
        href: https://immich.hydralab.lan
        description: Photos

- Identity:
    - Vaultwarden:
        icon: vaultwarden.png
        href: https://vaultwarden.hydralab.lan
        description: Password manager

- Docs:
    - Wiki.js:
        href: https://wiki.hydralab.lan
        description: Wiki

- Storage:
    - Unraid:
        icon: unraid.png
        href: http://<unraid-ip>
        description: Media array (VM)
```

Radarr, Sonarr, and qBittorrent share the Unraid VM's address, so they run on the Unraid VM.

Services behind Caddy link by `*.hydralab.lan` name; their IPs are in the [reverse proxy doc](../networking/reverse-proxy.md#proxied-services). Plex, the Unraid apps, and OPNsense aren't behind Caddy and stay on IPs.

## bookmarks.yaml

The default bookmarks (GitHub, Reddit, YouTube) are replaced with a link to this repo. The live file also has a link to a private config repo, not listed here.

```yaml
---
- Developer:
    - HomeLab Docs:
        - abbr: GH
          href: https://github.com/Ehenry8607/HomeLab
```
