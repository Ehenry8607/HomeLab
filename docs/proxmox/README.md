# Proxmox VE Cluster

## Nodes

| Node | Hardware | Role / notable workloads | Mgmt IP |
|---|---|---|---|
| `HydraServerMox` | TODO: | Primary node. ZFS storage, Unraid media VM | `<hydraserver-ip>` |
| `nuc-worker` | Intel NUC (TODO: model) | Plex VM (`103`) with Intel QuickSync passthrough | `<nuc-ip>` |
| `prodesk-worker` | HP ProDesk (TODO: model) | OPNsense VM (router/firewall), Caddy reverse proxy LXC (`102`) | `<prodesk-ip>` |
| `elitedesk-worker` | HP EliteDesk (TODO: model) | Added in a later expansion. Most service LXCs (Wazuh, Homepage, Wiki.js, …) and the `WIN-DC02` VM | `<elitedesk-ip>` |

OPNsense runs as a VM on `prodesk-worker`.

## Services

Every guest in the Proxmox cluster tree, as of 2026-10-28. IP / port is filled in where it's known; guests behind the [Caddy reverse proxy](../networking/reverse-proxy.md) are listed by name.

### `HydraServerMox`

| ID | Name | Type | IP / port | Notes |
|---|---|---|---|---|
| 100 | unraid | VM | `<unraid-ip>` | Media array (8TB disk). Prowlarr, Sonarr `:8989`, Radarr `:7878`, qBittorrent `:8080` run inside it. See [Media](../media/README.md) |
| 101 | k8s--control | VM | | |
| 104 | Win11real | VM | | |
| 106 | WindowsDC01 | VM | `<dc01-ip>` | `WIN-DC01`. See [Active Directory](../identity/active-directory.md) |
| 111 | HomeAssistant | VM | | |
| 120 | nextcloud-vm | VM | | |
| 127 | immich | LXC | `immich.hydralab.lan` | See [Immich](../media/immich.md) |

### `elitedesk-worker`

| ID | Name | Type | IP / port | Notes |
|---|---|---|---|---|
| 107 | actualbudget | LXC | | |
| 108 | beszel | LXC | | Monitoring hub, not set up; kept in case it's revisited |
| 109 | alpine-it-tools | LXC | | |
| 110 | vaultwarden | LXC | `vaultwarden.hydralab.lan` | Password manager. See [Vaultwarden](../security/vaultwarden.md) |
| 112 | uptimekuma | LXC | | |
| 113 | homepage | LXC | `homepage.hydralab.lan` | See [Homepage](../dashboard/homepage.md) |
| 115 | n8n | LXC | | |
| 116 | Kali | VM | | |
| 118 | wazuh | LXC | `wazuh.hydralab.lan` (agents: `<wazuh-ip>`) | See [Wazuh](../security/wazuh.md) |
| 119 | wikijs | LXC | `wiki.hydralab.lan` | |
| 121 | netbox | LXC | | |
| 122 | fluid-calendar | LXC | | |
| 123 | grafana | LXC | `grafana.hydralab.lan` | See [Monitoring](monitoring.md) |
| 124 | influxdb | LXC | `influxdb.hydralab.lan` | See [Monitoring](monitoring.md) |
| 125 | WindowsDC02 | VM | `<dc02-ip>` | `WIN-DC02` |
| 126 | splunk-enterprise | LXC | `splunk.hydralab.lan` | |
| 128 | rustdeskserver | LXC | TODO: confirm IP | Setup in progress. See [RustDesk server](../remote-access/rustdesk-server.md) |

### `nuc-worker`

| ID | Name | Type | IP / port | Notes |
|---|---|---|---|---|
| 103 | PlexServer | VM | `<plex-ip>:32400` | Ubuntu Server. See [Plex](../media/plex.md) |

### `prodesk-worker`

| ID | Name | Type | IP / port | Notes |
|---|---|---|---|---|
| 105 | OPNsense | VM | `<opnsense-ip>` | Router/firewall. See [Networking](../networking/README.md#opnsense) |
| 102 | Caddy | LXC | `<caddy-ip>:443` | Reverse proxy for `*.hydralab.lan`. See [Reverse proxy](../networking/reverse-proxy.md) |

Monitoring: Proxmox metrics go to InfluxDB and are graphed in Grafana. See [Monitoring](monitoring.md).

## Design

- **LXC first.** Each service runs in its own LXC unless it needs a full kernel (OPNsense, Windows DCs, Unraid).
- **ZFS** for VM/CT storage. Pools and disks per node: see [Storage](#storage).
- **Unraid as a VM** holds the media array; services moved out into LXCs during the migration.
- **Networking:** the bridge carrying OPNsense's LAN NIC is **VLAN aware** (`2-4094`), so new VLANs need no Proxmox changes. See [VLAN docs](../networking/vlans/README.md).

## Storage

### `HydraServerMox`

Captured 2026-10-28 with `lsblk -d -o NAME,SIZE,MODEL` and `zpool list`.

**Proxmox storages:** `localnetwork`, `Backup-Share`, `Containers`, `ISO-Share`, `NVMe-local`, `fast-pool`, `local`

**ZFS pools**

| Pool | Size | Allocated | Free | Health | Layout |
|---|---|---|---|---|---|
| `fast-pool` | 3.62T | 272G | 3.36T | **DEGRADED** | Mirror: SPCC SSD (`sdc`) + SanDisk Extreme (USB) |
| `local-storage` | 940G | 2.34G | 938G | ONLINE | Stripe: `nvme0n1` + `nvme1n1` (no redundancy; losing either disk loses the pool) |

**Disks**

| Device | Size | Model | Used for |
|---|---|---|---|
| `sda` | 7.3T | Seagate `ST8000DM004-2U9188` | Unraid array disk (media); Plex on `nuc-worker` uses it |
| `sdc` | 3.7T | SPCC Solid State Disk | `fast-pool` mirror |
| `sdd` | 119.2G | Timetec `35TT2280SATA-128GB` | Proxmox OS |
| `nvme0n1` | 465.8G | WD `WDS500G2B0C-00PXH0` | `local-storage` (striped) |
| `nvme1n1` | 476.9G | Kingston `OM8PGP4512Q-A0` | `local-storage` (striped) |
| `nvme2n1` | 465.8G | WD Green SN3000 500GB | Spare: one partition (`nvme2n1p1`), not mounted |
| (USB) | TODO: | SanDisk Extreme | `fast-pool` mirror; currently not detected |

**`fast-pool` is degraded (found 2026-10-28).** `zpool status` shows the SanDisk Extreme as REMOVED, and it doesn't appear in `lsblk`, so the OS isn't detecting it even though it's still plugged in. The SPCC half of the mirror is ONLINE with no data errors, so the pool has no redundancy until the SanDisk is back. Last scrub: 2026-08-09, 0 errors. TODO: find why the drive dropped (`lsusb`, `dmesg`), then `zpool online fast-pool <device>` or `zpool replace`.

`NVMe-local` in Proxmox is the `local-storage` pool. The Immich LXC (`127`) has a 950G mount point on it. See [Immich](../media/immich.md).

### `elitedesk-worker`

Captured 2026-10-28 with `lsblk -d -o NAME,SIZE,MODEL`.

**ZFS pools** (`zpool list`, 2026-10-28)

| Pool | Size | Allocated | Free | Health | Layout |
|---|---|---|---|---|---|
| `local-zfs` | 238G | 20.2G | 218G | ONLINE | Single disk: `nvme1n1` (no redundancy) |

**Proxmox storages:** `localnetwork`, `Backup-Share`, `ISO-Share`, `local`, `local-zfs`

**Disks**

| Device | Size | Model | Used for |
|---|---|---|---|
| `nvme0n1` | 238.5G | Samsung `MZALQ256HAJD-000L1` | Proxmox OS: 1G EFI, LVM `pve-root` 229G (`/`) and `pve-swap` 8G |
| `nvme1n1` | 238.5G | Samsung `MZVLB256HBHQ-000L7` | `local-zfs` pool |

### `nuc-worker`

Captured 2026-10-28 with `lsblk -d -o NAME,SIZE,MODEL`.

**ZFS pools:** none. Plex's media comes from the Unraid array on `HydraServerMox`.

**Proxmox storages:** `localnetwork`, `Backup-Share`, `ISO-Share`, `local`

**Disks**

| Device | Size | Model | Used for |
|---|---|---|---|
| `nvme0n1` | 238.5G | WD `PC SN730 SDBQNTY-256G-1001` | TODO: |

### `prodesk-worker`

Captured 2026-10-28 with `lsblk -d -o NAME,SIZE,MODEL`.

**ZFS pools:** none

**Disks**

| Device | Size | Model | Used for |
|---|---|---|---|
| `nvme0n1` | 238.5G | WD `PC SN520 SDAPNUW-256G-1006` | Proxmox OS: 1G EFI, LVM `pve-root` 229.5G (`/`) and `pve-swap` 8G |

## History: Unraid → Proxmox migration

HydraServer originally ran bare-metal Unraid. It was rebuilt as a Proxmox host with ZFS storage, Unraid demoted to a VM for the media array, and every service moved into its own LXC.

TODO: migration order and how data was moved.

## Useful commands

```bash
pvecm status                 # quorum and membership
pvecm nodes                  # node list
qm list                      # VMs on this node
pct list                     # containers on this node
zpool status                 # pool health
bridge -c vlan show          # VLANs carried by each bridge port
```
